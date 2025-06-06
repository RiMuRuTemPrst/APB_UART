`timescale 1ns / 1ps

//===============================================================================
// MODULE 1: UART BAUD RATE GENERATOR
//===============================================================================
module uart_baud_rate_generator #(
    parameter CLK_FREQ_HZ = 50_000_000,
    parameter BAUD_RATE   = 115200
)(
    input  wire clk,
    input  wire rst_n,
    output reg  baud_tick
);
    localparam integer DIVISOR = CLK_FREQ_HZ / BAUD_RATE;
    reg [$clog2(DIVISOR)-1:0] counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter   <= 0;
            baud_tick <= 0;
        end else begin
            if (counter == DIVISOR - 1) begin
                counter   <= 0;
                baud_tick <= 1'b1;
            end else begin
                counter   <= counter + 1;
                baud_tick <= 1'b0;
            end
        end
    end
endmodule


//===============================================================================
// MODULE 2: UART TRANSMITTER (Corrected Version)
//===============================================================================
module uart_tx (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        baud_tick,
    input  wire        tx_enable,
    input  wire [4:0]  cfg_reg,
    input  wire [7:0]  tx_data,
    output reg         tx,
    output reg         tx_busy,
    output reg         tx_done
);
    localparam  IDLE = 3'd0, START_BIT = 3'd1, DATA_BITS = 3'd2, PARITY_BIT = 3'd3, STOP_BITS = 3'd4;
    reg [2:0] state;
    reg [3:0] bit_counter;
    reg [7:0] tx_data_reg;
    reg [4:0] cfg_reg_reg;
    wire [1:0] data_bits_cfg = cfg_reg_reg[1:0];
    wire stop_bits_cfg = cfg_reg_reg[2];
    wire parity_en = cfg_reg_reg[3];
    wire parity_type = cfg_reg_reg[4];
    wire [3:0] data_bits_len = data_bits_cfg + 4'd5;
    wire [1:0] stop_bits_len = stop_bits_cfg ? 2'd2 : 2'd1;
    reg parity_bit;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_data_reg <= 8'd0; cfg_reg_reg <= 5'd0; parity_bit  <= 1'b0;
        end else if (tx_enable && state == IDLE) begin
            tx_data_reg <= tx_data; cfg_reg_reg <= cfg_reg;
            if (parity_en) begin
                case (cfg_reg[1:0])
                    2'b00: parity_bit <= cfg_reg[4] ? !(^tx_data[4:0]) : ^tx_data[4:0];
                    2'b01: parity_bit <= cfg_reg[4] ? !(^tx_data[5:0]) : ^tx_data[5:0];
                    2'b10: parity_bit <= cfg_reg[4] ? !(^tx_data[6:0]) : ^tx_data[6:0];
                    2'b11: parity_bit <= cfg_reg[4] ? !(^tx_data[7:0]) : ^tx_data[7:0];
                endcase
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE; tx <= 1'b1; tx_busy <= 1'b0; tx_done <= 1'b0; bit_counter <= 4'd0;
        end else begin
            if(tx_done) tx_done <= 1'b0;
            case (state)
                IDLE: begin
                    tx <= 1'b1; tx_busy <= 1'b0; bit_counter <= 4'd0;
                    if (tx_enable) begin tx_busy <= 1'b1; state <= START_BIT; end
                end
                START_BIT: if (baud_tick) begin state <= DATA_BITS; bit_counter <= 4'd0; tx <= 1'b0; end
                DATA_BITS: begin
                    tx <= tx_data_reg[bit_counter];
                    if (baud_tick) begin
                        if (bit_counter < data_bits_len - 1) bit_counter <= bit_counter + 1;
                        else begin bit_counter <= 4'd0; state <= parity_en ? PARITY_BIT : STOP_BITS; end
                    end
                end
                PARITY_BIT: if (baud_tick) begin state <= STOP_BITS; bit_counter <= 4'd0; tx <= parity_bit; end
                STOP_BITS: begin
                    tx <= 1'b1;
                    if (baud_tick) begin
                        if (bit_counter < stop_bits_len - 1) bit_counter <= bit_counter + 1;
                        else begin tx_done <= 1'b1; state <= IDLE; end
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule


//===============================================================================
// MODULE 3: UART RECEIVER (Final Oversampling Version)
//===============================================================================
module uart_rx #(
    parameter int CLK_FREQ_HZ = 50_000_000,
    parameter int BAUD_RATE   = 115200
)(
    input  logic clk, rst_n, rx,
    input  logic [4:0] cfg_reg,
    output logic [7:0] rx_data,
    output logic rx_done, parity_error
);
    typedef enum logic [2:0] {IDLE, START_CHECK, RECEIVE_DATA, RECEIVE_PARITY, RECEIVE_STOP} state_t;
    state_t state;
    localparam int OVERSAMPLE_RATE = 16;
    localparam int DIVISOR = CLK_FREQ_HZ / (BAUD_RATE * OVERSAMPLE_RATE);
    logic [$clog2(OVERSAMPLE_RATE):0] sample_counter;
    logic [2:0] bit_counter;
    logic [7:0] rx_shift_reg;
    logic parity_calc;
    logic rx_s1, rx_s2;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) {rx_s1, rx_s2} <= 2'b11; else {rx_s1, rx_s2} <= {rx, rx_s1};
    end
    wire rx_sync = rx_s2;
    wire rx_falling_edge = rx_s1 && !rx_s2;
    logic [$clog2(DIVISOR)-1:0] tick_counter;
    logic sample_tick;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) tick_counter <= '0;
        else if (tick_counter == DIVISOR - 1) tick_counter <= '0;
        else tick_counter <= tick_counter + 1;
    end
    assign sample_tick = (tick_counter == DIVISOR - 1);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE; rx_data <= '0; rx_done <= 1'b0; parity_error <= 1'b0;
            rx_shift_reg <= '0; bit_counter <= '0; sample_counter <= '0; parity_calc <= '0;
        end else begin
            if (rx_done) rx_done <= 1'b0;
            case (state)
                IDLE: if (rx_falling_edge) begin
                    state <= START_CHECK; sample_counter <= OVERSAMPLE_RATE / 2; parity_calc <= 1'b0;
                end
                START_CHECK: if (sample_tick) begin
                    if (sample_counter > 1) sample_counter <= sample_counter - 1;
                    else if (!rx_sync) begin
                        state <= RECEIVE_DATA; sample_counter <= OVERSAMPLE_RATE; bit_counter <= 0;
                    end else state <= IDLE;
                end
                RECEIVE_DATA: if (sample_tick) begin
                    if (sample_counter > 1) sample_counter <= sample_counter - 1;
                    else begin
                        sample_counter <= OVERSAMPLE_RATE; rx_shift_reg[bit_counter] <= rx_sync;
                        if (cfg_reg[3]) parity_calc <= parity_calc ^ rx_sync;
                        if (bit_counter == (cfg_reg[1:0] + 5) - 1) begin
                           state <= cfg_reg[3] ? RECEIVE_PARITY : RECEIVE_STOP;
                        end else bit_counter <= bit_counter + 1;
                    end
                end
                RECEIVE_PARITY: if (sample_tick) begin
                    if (sample_counter > 1) sample_counter <= sample_counter - 1;
                    else begin
                        if (cfg_reg[3]) parity_error <= ((parity_calc ^ rx_sync) != cfg_reg[4]);
                        state <= RECEIVE_STOP; sample_counter <= OVERSAMPLE_RATE; bit_counter <= 0;
                    end
                end
                RECEIVE_STOP: if (sample_tick) begin
                    if (sample_counter > 1) sample_counter <= sample_counter - 1;
                    else begin
                        if (bit_counter < (cfg_reg[2] ? 1 : 0)) begin
                            bit_counter <= bit_counter + 1; sample_counter <= OVERSAMPLE_RATE;
                        end else begin
                            if (rx_sync) rx_data <= rx_shift_reg;
                            rx_done <= 1'b1; state <= IDLE;
                        end
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule


//===============================================================================
// MODULE 4: LOOPBACK TESTBENCH
//===============================================================================
module uart_loopback_tb;
    parameter int CLK_FREQ_HZ = 50_000_000;
    parameter int BAUD_RATE   = 115200;
    parameter int CLK_PERIOD  = 20;

    logic clk, rst_n;
    logic [7:0] tx_data_in;
    logic [4:0] cfg_reg_in;
    logic start_tx_in;
    wire  serial_line;
    wire  tx_busy, tx_done, rx_done;
    wire [7:0] rx_data_out;
    
    // Instantiate ONLY the modules needed for the loopback test
    uart_baud_rate_generator #(.CLK_FREQ_HZ(CLK_FREQ_HZ), .BAUD_RATE(BAUD_RATE))
        baud_gen(.clk(clk), .rst_n(rst_n), .baud_tick(baud_tick));
    
    uart_tx tx_dut (
        .clk(clk), .rst_n(rst_n), .baud_tick(baud_tick), .tx_enable(start_tx_in),
        .cfg_reg(cfg_reg_in), .tx_data(tx_data_in), .tx(serial_line),
        .tx_busy(tx_busy), .tx_done(tx_done)
    );
        
    uart_rx #(.CLK_FREQ_HZ(CLK_FREQ_HZ), .BAUD_RATE(BAUD_RATE))
        rx_dut (
        .clk(clk), .rst_n(rst_n), .rx(serial_line), .cfg_reg(cfg_reg_in),
        .rx_data(rx_data_out), .rx_done(rx_done), .parity_error()
    );

    always #((CLK_PERIOD)/2) clk = ~clk;

    initial begin
        clk <= 0; rst_n <= 0; cfg_reg_in <= 5'b00011; tx_data_in <= '0; start_tx_in <= 1'b0;
        $display("T=%0t [TB] ====== Applying Reset ======", $time);
        #(CLK_PERIOD * 10);
        rst_n <= 1;
        $display("T=%0t [TB] ====== Reset Released, Starting Final Loopback Test ======", $time);
        #(CLK_PERIOD * 10);

        $display("\n[TB] --- Testing TX -> RX with character 'U' (0x55) ---");
        wait (tx_busy == 1'b0);
        @(posedge clk);
        $display("T=%0t [TB] TX is ready. Sending 'U'...", $time);
        tx_data_in <= 8'h55;
        start_tx_in <= 1'b1;
        @(posedge clk);
        start_tx_in <= 1'b0;

        $display("T=%0t [TB] TX initiated. Waiting for RX to complete...", $time);
        wait (rx_done == 1'b1);
        $display("T=%0t [TB] RX has finished!", $time);
        
        #(CLK_PERIOD);
        
        if (rx_data_out === 8'h55) begin
            $display("[TB] ---> PASSED! ✅  RX received 0x%h ('%c') as expected.", rx_data_out, rx_data_out);
        end else begin
            $display("[TB] ---> FAILED! ❌  RX received 0x%h, but expected 0x55.", rx_data_out);
        end

        #(CLK_PERIOD * 20);
        $display("\n\n[TB] ====== Final Test Finished ======");
        $finish;
    end
endmodule