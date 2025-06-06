`timescale 1ns / 1ps

module uart_top #(
    parameter CLK_FREQ_HZ = 50_000_000,
    parameter BAUD_RATE   = 115200
)(
    // System Signals
    input  wire        clk,
    input  wire        rst_n,

    // Control & Data Interface (from Register Block)
    input  wire [7:0]  tx_data_in,
    input  wire [4:0]  cfg_reg_in,
    input  wire        start_tx_in,

    // Status Interface (to Register Block)
    output wire        tx_done_out,
    output wire        rx_done_out,
    output wire        parity_error_out,
    output wire [7:0]  rx_data_out,
    output wire        tx_busy_out,

    // Physical UART and Flow Control Pins
    input  wire        rxd_in,
    output wire        txd_out,
    input  wire        cts_n_in,
    output wire        rts_n_out
);

    wire w_baud_tick;
    wire w_tx_enable;

    // 1. Baud Rate Generator (Vẫn cần thiết cho TX)
    uart_baud_rate_generator #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE  (BAUD_RATE)
    ) baud_gen_inst (
        .clk      (clk),
        .rst_n    (rst_n),
        .baud_tick(w_baud_tick)
    );

    // 2. UART Transmitter (Sử dụng baud_tick)
    uart_tx tx_inst (
        .clk        (clk),
        .rst_n      (rst_n),
        .baud_tick  (w_baud_tick),
        .tx_enable  (w_tx_enable),
        .cfg_reg    (cfg_reg_in),
        .tx_data    (tx_data_in),
        .tx         (txd_out),
        .tx_busy    (tx_busy_out),
        .tx_done    (tx_done_out)
    );

    // 3. UART Receiver (Sử dụng Oversampling và nhận cfg_reg)
    uart_rx #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE  (BAUD_RATE)
    ) rx_inst (
        .clk          (clk),
        .rst_n        (rst_n),
        .rx           (rxd_in),
        .cfg_reg      (cfg_reg_in), // <<-- KẾT NỐI LẠI CỔNG NÀY
        .rx_data      (rx_data_out),
        .rx_done      (rx_done_out),
        .parity_error (parity_error_out)
    );

    // 4. RTS/CTS Flow Control Logic
    rts_cts_logic flow_control_inst (
        .clk      (clk),
        .reset_n  (rst_n),
        .start_tx (start_tx_in),
        .tx_busy  (tx_busy_out),
        .cts      (cts_n_in),
        .rts      (rts_n_out),
        .tx_enable(w_tx_enable)
    );

endmodule