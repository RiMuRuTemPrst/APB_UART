`timescale 1ns / 1ps

// UART Receiver with Oversampling - Final Corrected Version
module uart_rx #(
    parameter int CLK_FREQ_HZ = 50_000_000,
    parameter int BAUD_RATE   = 115200
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        rx,
    input  logic [4:0]  cfg_reg,

    output logic [7:0]   rx_data,
    output logic         rx_done,
    output logic         parity_error
);

    // FSM states defined using a type-safe enumeration
    typedef enum logic [2:0] {
        IDLE,
        START_CHECK,
        RECEIVE_DATA,
        RECEIVE_PARITY,
        RECEIVE_STOP // Tên đúng
    } state_t;

    state_t state;
                
    localparam int OVERSAMPLE_RATE = 16;
    localparam int DIVISOR = CLK_FREQ_HZ / (BAUD_RATE * OVERSAMPLE_RATE);

    logic [$clog2(OVERSAMPLE_RATE):0] sample_counter;
    logic [2:0]                       bit_counter;
    logic [7:0]                       rx_shift_reg;
    logic                             parity_calc;

    // Input Synchronizer
    logic rx_s1, rx_s2;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) {rx_s1, rx_s2} <= 2'b11;
        else        {rx_s1, rx_s2} <= {rx, rx_s1};
    end
    wire rx_sync = rx_s2;
    wire rx_falling_edge = rx_s1 && !rx_s2;

    // Free-running Oversampling Tick Generator
    logic [$clog2(DIVISOR)-1:0] tick_counter;
    logic sample_tick;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)                   tick_counter <= '0;
        else if (tick_counter == DIVISOR - 1) tick_counter <= '0;
        else                          tick_counter <= tick_counter + 1;
    end
    assign sample_tick = (tick_counter == DIVISOR - 1);

    // Main FSM and Datapath Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE; rx_data <= '0; rx_done <= 1'b0; parity_error <= 1'b0;
            rx_shift_reg <= '0; bit_counter <= '0; sample_counter <= '0; parity_calc <= '0;
        end else begin
            if (rx_done) rx_done <= 1'b0;

            case (state)
                IDLE: begin
                    if (rx_falling_edge) begin
                        state <= START_CHECK;
                        sample_counter <= OVERSAMPLE_RATE / 2;
                        parity_calc    <= 1'b0;
                    end
                end

                START_CHECK: begin
                    if (sample_tick) begin
                        if (sample_counter > 1) begin
                            sample_counter <= sample_counter - 1;
                        end else begin
                            if (!rx_sync) begin
                                state <= RECEIVE_DATA;
                                sample_counter <= OVERSAMPLE_RATE;
                                bit_counter <= 0;
                            end else state <= IDLE;
                        end
                    end
                end

                RECEIVE_DATA: begin
                    if (sample_tick) begin
                        if (sample_counter > 1) begin
                            sample_counter <= sample_counter - 1;
                        end else begin
                            sample_counter <= OVERSAMPLE_RATE;
                            rx_shift_reg[bit_counter] <= rx_sync;
                            if (cfg_reg[3]) parity_calc <= parity_calc ^ rx_sync;
                            
                            if (bit_counter == (cfg_reg[1:0] + 5) - 1) begin
                                bit_counter <= 0;
                                // <<<<< SỬA LỖI Ở ĐÂY >>>>>
                                state       <= cfg_reg[3] ? RECEIVE_PARITY : RECEIVE_STOP;
                            end else begin
                                bit_counter <= bit_counter + 1;
                            end
                        end
                    end
                end

                RECEIVE_PARITY: begin
                    if (sample_tick) begin
                        if (sample_counter > 1) sample_counter <= sample_counter - 1;
                        else begin
                            if (cfg_reg[3]) parity_error <= ((parity_calc ^ rx_sync) != cfg_reg[4]);
                            // <<<<< SỬA LỖI Ở ĐÂY >>>>>
                            state <= RECEIVE_STOP; 
                            sample_counter <= OVERSAMPLE_RATE;
                            bit_counter <= 0;
                        end
                    end
                end

                RECEIVE_STOP: begin
                    if (sample_tick) begin
                        if (sample_counter > 1) sample_counter <= sample_counter - 1;
                        else begin
                            if (bit_counter < (cfg_reg[2] ? 1 : 0)) begin
                                bit_counter <= bit_counter + 1;
                                sample_counter <= OVERSAMPLE_RATE;
                            end else begin
                                if (rx_sync) rx_data <= rx_shift_reg;
                                rx_done <= 1'b1;
                                state   <= IDLE;
                            end
                        end
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule