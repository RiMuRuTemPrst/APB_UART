// Module: uart_baud_rate_generator
// Description: Generates baud_tick for UART TX/RX based on clock divider

module uart_baud_rate_generator #(
    parameter CLK_FREQ_HZ = 4,   // System clock frequency (50 MHz on DE2)
    parameter BAUD_RATE    = 2       // Target UART baud rate
)(
    input  wire clk,
    input  wire rst_n,
    output reg  baud_tick
);

    // Compute divider value
    localparam integer DIVISOR = CLK_FREQ_HZ / BAUD_RATE;
    localparam integer COUNTER_WIDTH = $clog2(DIVISOR);

    reg [COUNTER_WIDTH-1:0] counter;

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
