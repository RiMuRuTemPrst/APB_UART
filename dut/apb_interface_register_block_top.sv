`timescale 1ns / 1ps

module apb_interface_register_block_top (
    // APB Bus signals
    input  wire        pclk,
    input  wire        presetn,
    input  wire        psel,
    input  wire        penable,
    input  wire        pwrite,
    input  wire [12:0] paddr,
    input  wire [31:0] pwdata,
    input  wire [3:0]  pstrb,

    output wire        pready,
    output wire [31:0] prdata,
    output wire        pslverr,

    // UART TX/RX Interface
    input  wire        set_tx_done,
    input  wire        set_rx_done,
    input  wire        set_parity_error,
    input  wire [7:0]  rx_data_in,
    output wire [7:0]  tx_data_out,
    output wire        start_tx,
    output wire [4:0]  cfg_reg_out
);

    // Wires connecting the two modules
    wire [12:0] reg_addr;
    wire [31:0] reg_wdata;
    wire [3:0]  reg_strb;
    wire        reg_we;
    wire [31:0] reg_rdata;

    apb_interface apb_interface_inst (
        .pclk       (pclk),
        .presetn    (presetn),
        .psel       (psel),
        .penable    (penable),
        .pwrite     (pwrite),
        .paddr      (paddr),
        .pwdata     (pwdata),
        .pstrb      (pstrb),
        .pready     (pready),
        .prdata     (prdata),
        .pslverr    (pslverr),
        .reg_addr_o (reg_addr),
        .reg_wdata_o(reg_wdata),
        .reg_strb_o (reg_strb),
        .reg_we_o   (reg_we),
        .reg_rdata_i(reg_rdata)
    );

    register_block register_block_inst (
        .pclk        (pclk),
        .presetn     (presetn),
        .reg_addr_i  (reg_addr),
        .reg_wdata_i (reg_wdata),
        .reg_strb_i  (reg_strb),
        .reg_we_i    (reg_we),
        .reg_rdata_o (reg_rdata),

        .set_tx_done      (set_tx_done),
        .set_rx_done      (set_rx_done),
        .set_parity_error (set_parity_error),
        .rx_data_in       (rx_data_in),
        .tx_data_out      (tx_data_out),
        .start_tx         (start_tx),
        .cfg_reg_out      (cfg_reg_out)
    );

endmodule