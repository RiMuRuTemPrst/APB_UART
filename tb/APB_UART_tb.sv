`timescale 1ns / 1ps

// Testbench for the complete apb_uart_top system
module apb_uart_tb;

    //===============================================================================
    // Parameters
    //===============================================================================
    parameter int CLK_FREQ_HZ = 50_000_000;
    parameter int BAUD_RATE   = 100000;
    
    parameter int CLK_PERIOD  = 20; // 20ns = 50MHz

    // APB Address Map
    localparam TX_DATA_ADDR = 13'h000;
    localparam RX_DATA_ADDR = 13'h004;
    localparam CFG_ADDR     = 13'h008;
    localparam CTRL_ADDR    = 13'h00C;
    localparam STT_ADDR     = 13'h010;
    
    //===============================================================================
    // Signals
    //===============================================================================
    logic        pclk;
    logic        presetn;
    logic        psel;
    logic        penable;
    logic        pwrite;
    logic [12:0] paddr;
    logic [31:0] pwdata;
    logic [3:0]  pstrb;
    
    // The "Loopback Wire" connects TXD output to RXD input
    wire         loopback_line; 
    logic        uart_cts_n; // Clear-To-Send, tied low to indicate UART is always clear to send

    wire         pready;
    wire [31:0]  prdata;
    wire         pslverr;
    wire         uart_rts_n;

    //===============================================================================
    // Instantiate the Device Under Test (DUT)
    //===============================================================================
    apb_uart_top #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE  (BAUD_RATE)
    ) dut (
        .pclk(pclk), .presetn(presetn), .psel(psel), .penable(penable), .pwrite(pwrite),
        .paddr(paddr), .pwdata(pwdata), .pstrb(pstrb), .pready(pready), .prdata(prdata),
        .pslverr(pslverr), 
        
        // <<-- KẾT NỐI LOOPBACK -->>
        .uart_rxd(loopback_line), 
        .uart_txd(loopback_line), 
        
        .uart_cts_n(uart_cts_n), 
        .uart_rts_n(uart_rts_n)
    );
    
    //===============================================================================
    // Clock Generator & APB Tasks
    //===============================================================================
    always #((CLK_PERIOD)/2) pclk = ~pclk;

    task apb_write(input [12:0] address, input [31:0] data, input [3:0] strobe);
        @(posedge pclk);
        psel <= 1'b1; paddr <= address; pwrite <= 1'b1;
        pwdata <= data; pstrb <= strobe;
        @(posedge pclk);
        penable <= 1'b1;
        wait (pready == 1'b1);
        @(posedge pclk);
        psel <= 1'b0; penable <= 1'b0;
    endtask

    task apb_read(input [12:0] address);
        @(posedge pclk);
        psel <= 1'b1; paddr <= address; pwrite <= 1'b0;
        @(posedge pclk);
        penable <= 1'b1;
        wait (pready == 1'b1);
        @(posedge pclk);
        psel <= 1'b0; penable <= 1'b0;
    endtask

    //===============================================================================
    // Main Test Sequence
    //===============================================================================
    initial begin
        pclk <= 0; presetn <= 0; psel <= 0; penable <= 0; pwrite <= 0;
        paddr <= 0; pwdata <= 0; pstrb <= 0;
        uart_cts_n <= 1'b0; // Giả định rằng thiết bị nhận luôn sẵn sàng
        
        $display("T=%0t [TB] ====== Applying Reset ======", $time);
        #(CLK_PERIOD * 10);
        presetn <= 1;
        $display("T=%0t [TB] ====== Reset Released, Starting System Loopback Test ======", $time);

        // --- Step 1: Configure UART for 8-N-1 via APB ---
        $display("\n[TB] --- Configuring UART for 8-N-1 ---");
        apb_write(CFG_ADDR, 32'h03, 4'b0001);
        $display("[TB] Configuration sent.");

        // --- Step 2: Transmit character 'V' (0x56) via APB ---
        $display("\n[TB] --- Transmitting character 'V' (0x56) ---");
        apb_write(TX_DATA_ADDR, 32'h56, 4'b0001);
        apb_write(CTRL_ADDR, 32'h01, 4'b0001); // Set start_tx bit
        apb_write(CTRL_ADDR, 32'h00, 4'b0001); // Clear start_tx bit to prevent re-transmission
        $display("T=%0t [TB] TX initiated via APB.", $time);

        // --- Step 3: Wait for RX to complete by polling Status Register ---
        $display("T=%0t [TB] Waiting for RX to complete...", $time);
        
        do begin
            #(CLK_PERIOD * 200);
            apb_read(STT_ADDR);
            $display("T=%0t [TB] Polling STT_REG, value = %h", $time, prdata);
        end while (prdata[1] == 1'b0); // Bit 1 is rx_done
        
        $display("T=%0t [TB] ---> RX Done flag is set!", $time);

        // --- Step 4: Read back received data and verify ---
        apb_read(RX_DATA_ADDR);
        
        // <<<<< SỬA LỖI TẠI ĐÂY: KIỂM TRA BYTE CAO NHẤT [31:24] >>>>>
        if (prdata[31:24] == 8'h56) begin
            $display("[TB] ---> PASSED! ✅  RX received 0x%h ('%c') as expected.", prdata[31:24], prdata[31:24]);
        end else begin
            $display("[TB] ---> FAILED! ❌  RX received 0x%h, but expected 0x56.", prdata[31:24]);
        end
        
        #(CLK_PERIOD * 20);
        $display("\n\n[TB] ====== APB System Loopback Test Finished ======");
        $finish;
    end

endmodule