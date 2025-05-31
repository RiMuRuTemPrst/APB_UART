module apb_uart_top #(
    parameter CLK_FREQ_HZ    = 50_000_000,
    parameter BAUD_RATE      = 115200,
    parameter TIMEOUT_CYCLES = CLK_FREQ_HZ * 1
)(
    input  wire        clk,          // System Clock
    input  wire        rst_n,        // System Reset, active LOW

    // APB interface signals
    input  wire        pclk,         // APB clock
    input  wire        presetn,      // APB reset, active LOW
    input  wire        psel,         // APB select
    input  wire        penable,      // APB enable
    input  wire        pwrite,       // APB write
    input  wire [12:0] paddr,        // APB address
    input  wire [31:0] pwdata,       // APB write data
    input  wire [3:0]  pstrb,        // Byte strobe

    output wire [31:0] prdata,       // APB read data
    output wire        pslverr,      // APB slave error
    output wire        pready,       // APB ready

    // UART physical signals
    input  wire        rx,           // UART receive
    input  wire        cts_n,        // Clear To Send (active low)
    output wire        tx,           // UART transmit
    output wire        rts_n         // Request To Send (active low)
);

    //===============================================================================
    // APB Interface <-> Register Block
    //===============================================================================
    wire [7:0]  data_write_to_reg;
    wire [7:0]  data_read;     //Data APB read from register block
    wire [4:0]  reg_address_des;
    wire        start_tx_signal;
    wire        tx_done_signal;
    wire        rx_done_signal;
    wire        parity_error_signal;
    

    // Internal UART <-> register_block
    wire        tx_enable;
    wire        tx_busy;
    wire [4:0]  cfg_reg_out;
    wire [7:0]  tx_data_out;
    wire        tx_done;       // Signal to indicate TX done
    wire        rx_done;       // Signal to indicate RX done
    wire        parity_error;  // Signal to indicate parity error
    wire        start_tx;     // Signal to start transmission
    wire        baud_tick;

    //===============================================================================
    // APB interface logic
    //===============================================================================
    apb_interface #(
        .TIMEOUT_CYCLES(TIMEOUT_CYCLES)
    ) apb_if (
        .pclk                (pclk),
        .presetn             (presetn),
        .psel                (psel),
        .penable             (penable),
        .pwrite              (pwrite),
        .paddr               (paddr),
        .pwdata              (pwdata),
        .pstrb               (pstrb),
        .pready              (pready),
        .prdata              (prdata),
        .pslverr             (pslverr),
        .reg_address_des     (reg_address_des),
        .data_write_to_reg   (data_write_to_reg),
        .start_tx_signal     (start_tx_signal),
        .data_read           (data_read),
        .tx_done_signal      (tx_done_signal),
        .rx_done_signal      (rx_done_signal),
        .parity_error_signal (parity_error_signal)
    );

    //===============================================================================
    // Register block
    //===============================================================================
    register_block reg_blk (
        .pclk                (pclk),
        .presetn             (presetn),
        .psel                (psel),
        .penable             (penable),
        .pwrite              (pwrite),
        .pslverr             (pslverr),
        .reg_address_des     (reg_address_des),
        .data_write_to_reg   (data_write_to_reg),
        .start_tx_signal     (start_tx_signal),
        .data_to_APB         (data_read),
        .tx_done_signal      (tx_done_signal),
        .rx_done_signal      (rx_done_signal),
        .parity_error_signal (parity_error_signal),
        .set_tx_done         (tx_done),
        .set_rx_done         (rx_done),
        .set_parity_error    (parity_error),
        .data_read           (rx_data),
        .tx_data_out         (tx_data_out),
        .start_tx            (start_tx),
        .cfg_reg_out         (cfg_reg_out),
    );

    //===============================================================================
    // RTS/CTS Logic
    //===============================================================================
    rts_cts_logic rts_cts (
        .clk         (clk),
        .reset_n     (rst_n),
        .start_tx    (start_tx),
        .tx_busy     (tx_busy),
        .cts         (cts_n),
        .rts         (rts_n),
        .tx_enable   (tx_enable)
    );

    //===============================================================================
    // UART Baud Rate Generator
    //===============================================================================
    uart_baud_rate_generator #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE  (BAUD_RATE)
    ) baud_gen (
        .clk       (clk),
        .rst_n     (rst_n),
        .baud_tick (baud_tick)
    );

    //===============================================================================
    // UART Transmitter
    //===============================================================================
    uart_tx uart_tx_inst (
        .clk        (clk),
        .rst_n      (rst_n),
        .baud_tick  (baud_tick),
        .tx_enable  (tx_enable),
        .cfg_reg    (cfg_reg_out),
        .tx_data    (tx_data_out),
        .tx         (tx),
        .tx_busy    (tx_busy),
        .tx_done    (tx_done)
    );

    //===============================================================================
    // UART Receiver
    //===============================================================================
    uart_rx uart_rx_inst (
        .clk          (clk),
        .rst_n        (rst_n),
        .baud_tick    (baud_tick),
        .rx           (rx),
        .cfg_reg      (cfg_reg_out),
        .rx_data      (rx_data),
        .rx_done      (rx_done),
        .parity_error (parity_error)
    );

endmodule
