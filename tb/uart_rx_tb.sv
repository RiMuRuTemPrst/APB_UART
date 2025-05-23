`timescale 1ns/1ps

module uart_rx_tb;
    // Clock & baud parameters
    localparam CLK_PERIOD = 20;    // 50 MHz
    localparam BAUD_DIV    = 434;   // ~115200 baud
    localparam BIT_TIME    = CLK_PERIOD * BAUD_DIV;

    // Signals
    reg        clk       = 0;
    reg        rst_n     = 0;
    reg        baud_tick = 0;
    reg        rx        = 1;
    reg [4:0]  cfg_reg   = 5'b01001; // 5-bit data, even parity, 1 stop
    wire [7:0] rx_data;
    wire       rx_done;
    wire       parity_error;

    // DUT instantiation
    uart_rx uut (
        .clk(clk),
        .rst_n(rst_n),
        .baud_tick(baud_tick),
        .rx(rx),
        .cfg_reg(cfg_reg),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .parity_error(parity_error)
    );

    // Waveform dump only
    initial begin
        $dumpfile("uart_rx_tb.vcd");
        $dumpvars(0, uart_rx_tb);
    end

    // Clock generator
    always #(CLK_PERIOD/2) clk = ~clk;

    // Baud tick generator
    integer baud_cnt = 0;
    always @(posedge clk) begin
        if (baud_cnt == BAUD_DIV-1) begin
            baud_cnt  <= 0;
            baud_tick <= 1;
        end else begin
            baud_cnt  <= baud_cnt + 1;
            baud_tick <= 0;
        end
    end

    // Task to send one frame based on fixed cfg_reg
    task send_frame(input [7:0] data_in);
        integer data_len;
        integer stop_len;
        integer i;
        reg parity_calc;
        begin
            case (cfg_reg[1:0])
                2'b00: data_len = 5;
                2'b01: data_len = 6;
                2'b10: data_len = 7;
                default: data_len = 8;
            endcase
            stop_len = cfg_reg[2] ? 2 : 1;

            // Start bit
            rx = 0; #BIT_TIME;

            // Data bits LSB-first
            parity_calc = 0;
            for (i = 0; i < data_len; i = i + 1) begin
                rx = data_in[i];
                parity_calc = parity_calc ^ data_in[i];
                #BIT_TIME;
            end

            // Parity bit
            if (cfg_reg[3]) begin
                rx = (cfg_reg[4]) ? ~parity_calc : parity_calc;
                #BIT_TIME;
            end

            // Stop bits
            rx = 1;
            for (i = 0; i < stop_len; i = i + 1) #BIT_TIME;
        end
    endtask

    // Multiple test bytes with same config
    initial begin
        // Reset deassert
        #100; rst_n = 1;

        // Align
        #(BIT_TIME/2);

        // Send test bytes
        send_frame(8'hA5);
        #(BIT_TIME);
        send_frame(8'h5A);
        #(BIT_TIME);
        send_frame(8'hFF);
        #(BIT_TIME);
        send_frame(8'h00);
        #(BIT_TIME*2);
        send_frame(8'hC3);
        #(BIT_TIME);
        send_frame(8'h6D);
        #(BIT_TIME);
        send_frame(8'hD2);
        #(BIT_TIME);
        send_frame(8'h2D);
        #(BIT_TIME);
        send_frame(8'hB4);
        #(BIT_TIME);
        send_frame(8'h17);
        #(BIT_TIME);
        send_frame(8'hE8);
        #(BIT_TIME);

        $finish;
    end
endmodule
