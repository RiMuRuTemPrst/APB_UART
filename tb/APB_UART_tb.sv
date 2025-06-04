`timescale 1ns/1ps
module apb_uart_tb;
    //===========================================================================
    // Parameters
    //===========================================================================
    localparam CLK_FREQ_HZ     = 50_000_000;      // 50 MHz system clock
    localparam BAUD_RATE       = 115200;          // UART baud rate
    localparam CLK_PERIOD_NS   = 20;              // 20 ns period ⇒ 50 MHz
    localparam PCLK_PERIOD_NS  = 20;              // Use 50 MHz for APB clock as well

    //===========================================================================
    // Testbench Signals
    //===========================================================================
    reg         clk;
    reg         rst_n;

    // APB interface signals
    reg         pclk;
    reg         presetn;
    reg         psel;
    reg         penable;
    reg         pwrite;
    reg  [12:0] paddr;
    reg  [31:0] pwdata;
    reg  [ 3:0] pstrb;
    wire [31:0] prdata;
    wire        pslverr;
    wire        pready;

    // UART physical pins
    wire        tx;
    wire        rx;
    reg         cts_n;
    wire        rts_n;

    //===========================================================================
    // Instantiate DUT (apb_uart_top)
    //===========================================================================
    apb_uart_top #(
        .CLK_FREQ_HZ    (CLK_FREQ_HZ),
        .BAUD_RATE      (BAUD_RATE),
        .TIMEOUT_CYCLES (CLK_FREQ_HZ * 1)
    ) uut (
        .clk      (clk),
        .rst_n    (rst_n),

        // APB interface
        .pclk     (pclk),
        .presetn  (presetn),
        .psel     (psel),
        .penable  (penable),
        .pwrite   (pwrite),
        .paddr    (paddr),
        .pwdata   (pwdata),
        .pstrb    (pstrb),
        .prdata   (prdata),
        .pslverr  (pslverr),
        .pready   (pready),

        // UART physical
        .rx       (rx),
        .cts_n    (cts_n),
        .tx       (tx),
        .rts_n    (rts_n)
    );

    //===========================================================================
    // Loopback for TX→RX (optional; here RX idles high)
    //===========================================================================
    assign rx = 1'b1;  // For a pure-TX test, keep RX idle high

    //===========================================================================
    // Clock Generation
    initial 
    begin
        clk = 1'b0;
        forever #(CLK_PERIOD_NS / 2) clk = ~clk; // Toggle clock every half period
    end

    initial 
    begin
        pclk = 1'b0;
        forever #(PCLK_PERIOD_NS / 2) pclk = ~pclk; // Toggle APB clock
    end

    initial 
    begin
        psel = 1'b1;
        cts_n = 1'b0; // CTS active low
        rst_n = 1'b1; // Start with reset active

        #1000; 
        paddr = 13'h0000; // APB address for UART control
        pwdata = 32'h76543210; // Initial data
        pstrb = 4'b1111; // Write all bytes
        pwrite = 1'b1; // Write operation
        presetn = 1'b1; // Release reset

        #1000;
        penable = 1'b1; // Enable APB transaction

        #1000;
        wait (pready);

        #1000;
        $finish;

    end


endmodule
