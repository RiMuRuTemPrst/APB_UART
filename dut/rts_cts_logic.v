module rts_cts_logic (
    input  wire clk,        // xung APB hoặc hệ thống
    input  wire reset_n,    // reset bất đồng bộ, active LOW
    input  wire start_tx,   // pulse từ Register_Block: yêu cầu truyền
    input  wire tx_busy,    // từ UART_Transmitter: đang truyền
    input  wire cts,        // Clear-To-Send từ ngoại vi (active LOW)
    output reg  rts,        // Request-To-Send ra ngoại vi (active LOW)
    output wire tx_enable   // cấp cho UART_Transmitter
);

    // tx_enable = 1 khi:
    //  - có lệnh start_tx
    //  - UART chưa bận (tx_busy=0)
    //  - ngoại vi cho phép (cts=0 vì active LOW)
    assign tx_enable = start_tx & ~tx_busy & ~cts;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // reset ⇒ de-assert RTS (1)
            rts <= 1'b1;
        end else begin
            // assert RTS (0) khi mới có start_tx hoặc còn tx_busy;
            // de-assert (1) khi không còn yêu cầu gửi nữa (start_tx=0) và UART không bận (tx_busy=0)
            rts <= ~(start_tx | tx_busy);
        end
    end

endmodule
