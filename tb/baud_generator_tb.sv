// File: uart_baud_rate_generator.sv

module uart_baud_rate_generator #(
    parameter CLK_FREQ_HZ   = 50_000_000,
    parameter BAUD_RATE     = 115200
)(
    input  wire clk,
    input  wire rst_n,
    output reg  baud_tick
);

    // <<<<< SỬA LỖI Ở ĐÂY: Thêm logic làm tròn >>>>>
    // Compute divider value with rounding
    localparam integer DIVISOR = (CLK_FREQ_HZ + (BAUD_RATE / 2)) / BAUD_RATE;
    
    localparam integer COUNTER_WIDTH = $clog2(DIVISOR);

    reg [COUNTER_WIDTH-1:0] counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter   <= 0;
            baud_tick <= 0;
        end else begin
            if (counter >= DIVISOR - 1) begin // Dùng >= để an toàn hơn
                counter   <= 0;
                baud_tick <= 1'b1;
            end else begin
                counter   <= counter + 1;
                baud_tick <= 1'b0;
            end
        end
    end

endmodule