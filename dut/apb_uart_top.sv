`timescale 1ns / 1ps

//===============================================================================
// Module: apb_uart_top
// Description:
//   Top-level module for the entire APB-to-UART system.
//   Instantiates and connects the APB interface, the register block,
//   and the core UART logic block (uart_top).
//===============================================================================
module apb_uart_top #(
    parameter CLK_FREQ_HZ = 50_000_000,
    parameter BAUD_RATE   = 115200
)(
    // APB Interface
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

    // Physical UART Pins
    input  wire        uart_rxd,
    output wire        uart_txd,
    input  wire        uart_cts_n,
    output wire        uart_rts_n
);

    //===============================================================================
    // Wires connecting the major blocks
    //===============================================================================

    // --- Wires between APB Interface and Register Block ---
    wire [12:0] w_reg_addr;
    wire [31:0] w_reg_wdata;
    wire [3:0]  w_reg_strb;
    wire        w_reg_we;
    wire [31:0] w_reg_rdata;

    // --- Wires between Register Block and UART Core ---
    wire [7:0]  w_tx_data_to_uart;
    wire [4:0]  w_cfg_reg_to_uart;
    wire        w_start_tx_to_uart;
    wire        w_tx_done_from_uart;
    wire        w_rx_done_from_uart;
    wire        w_parity_err_from_uart;
    wire [7:0]  w_rx_data_from_uart;
    wire        w_tx_busy_from_uart;


    //===============================================================================
    // Instantiations
    //===============================================================================

    // 1. APB Interface Block
    // Translates APB transactions into simple read/write signals
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
        
        .reg_addr_o (w_reg_addr),
        .reg_wdata_o(w_reg_wdata),
        .reg_strb_o (w_reg_strb),
        .reg_we_o   (w_reg_we),
        .reg_rdata_i(w_reg_rdata)
    );

    // 2. Register Block
    // Holds configuration, status, and data registers
    register_block register_block_inst (
        .pclk             (pclk),
        .presetn          (presetn),
        .reg_addr_i       (w_reg_addr),
        .reg_wdata_i      (w_reg_wdata),
        .reg_strb_i       (w_reg_strb),
        .reg_we_i         (w_reg_we),
        .reg_rdata_o      (w_reg_rdata),
        
        .set_tx_done      (w_tx_done_from_uart),
        .set_rx_done      (w_rx_done_from_uart),
        .set_parity_error (w_parity_err_from_uart),
        .rx_data_in       (w_rx_data_from_uart),
        
        .tx_data_out      (w_tx_data_to_uart),
        .start_tx         (w_start_tx_to_uart),
        .cfg_reg_out      (w_cfg_reg_to_uart)
    );
        
    // 3. UART Core Block
    // Contains the actual UART logic (TX, RX, Baud Gen, Flow Control)
    uart_top #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE  (BAUD_RATE)
    ) uart_core_inst (
        .clk              (pclk),
        .rst_n            (presetn),
        .tx_data_in       (w_tx_data_to_uart),
        .cfg_reg_in       (w_cfg_reg_to_uart),
        .start_tx_in      (w_start_tx_to_uart),
        
        .tx_done_out      (w_tx_done_from_uart),
        .rx_done_out      (w_rx_done_from_uart),
        .parity_error_out (w_parity_err_from_uart),
        .rx_data_out      (w_rx_data_from_uart),
        .tx_busy_out      (w_tx_busy_from_uart), // Note: tx_busy is not used by this register_block
        
        .rxd_in           (uart_rxd),
        .txd_out          (uart_txd),
        .cts_n_in         (uart_cts_n),
        .rts_n_out        (uart_rts_n)
    );

endmodule