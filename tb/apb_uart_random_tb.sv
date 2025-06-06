`timescale 1ns / 1ps

// Testbench kiểm thử loopback với việc reset trước mỗi test case
module apb_uart_random_tb;

    //===============================================================================
    // Parameters
    //===============================================================================
    parameter int CLK_PERIOD      = 20;    // 20ns = 50MHz
    // <<<< Quay lại Baud Rate ban đầu để kiểm chứng giả thuyết >>>>
    parameter int BAUD_RATE       = 115200; 
    parameter int NUM_TESTS       = 10000;
    
    localparam int BIT_PERIOD_NS = 1_000_000_000 / BAUD_RATE;

    // APB Address Map
    localparam TX_DATA_ADDR = 13'h000;
    localparam RX_DATA_ADDR = 13'h004;
    localparam CFG_ADDR     = 13'h008;
    localparam CTRL_ADDR    = 13'h00C;
    localparam STT_ADDR     = 13'h010;
    
    //===============================================================================
    // Signals & DUT Instantiation (Giữ nguyên)
    //===============================================================================
    logic        pclk;
    logic        presetn;
    logic        psel, penable, pwrite;
    logic [12:0] paddr;
    logic [31:0] pwdata;
    logic [3:0]  pstrb;
    wire         pready;
    wire [31:0]  prdata;
    wire         pslverr;
    wire         uart_rts_n;
    wire         loopback_line;

    apb_uart_top dut (
        .pclk(pclk), .presetn(presetn), .psel(psel), .penable(penable), .pwrite(pwrite),
        .paddr(paddr), .pwdata(pwdata), .pstrb(pstrb), .pready(pready), .prdata(prdata),
        .pslverr(pslverr), .uart_rxd(loopback_line), .uart_txd(loopback_line),
        .uart_cts_n(1'b0), .uart_rts_n(uart_rts_n)
    );
    
    //===============================================================================
    // Clock Generator & APB Tasks (Giữ nguyên)
    //===============================================================================
    always #((CLK_PERIOD)/2) pclk = ~pclk;

    task apb_write(input [12:0] address, input [31:0] data, input [3:0] strobe);
        @(posedge pclk); psel <= 1'b1; paddr <= address; pwrite <= 1'b1;
        pwdata <= data; pstrb <= strobe; @(posedge pclk);
        penable <= 1'b1; wait (pready == 1'b1); @(posedge pclk);
        psel <= 1'b0; penable <= 1'b0;
    endtask

    task apb_read(input [12:0] address);
        @(posedge pclk); psel <= 1'b1; paddr <= address; pwrite <= 1'b0;
        @(posedge pclk); penable <= 1'b1;
        wait (pready == 1'b1); @(posedge pclk);
        psel <= 1'b0; penable <= 1'b0;
    endtask

    //===============================================================================
    // Main Loopback Test Sequence (Logic Reset được chuyển vào trong vòng lặp)
    //===============================================================================
    initial begin
        int unsigned passed_count;
        int unsigned failed_count;
        passed_count = 0;
        failed_count = 0;

        // Khởi tạo ban đầu
        pclk <= 0;
        presetn <= 1; // Bắt đầu ở trạng thái không reset
        
        for (int i = 0; i < NUM_TESTS; i++) begin
            logic [7:0] tx_char;
            logic [7:0] rx_char;
            tx_char = $urandom_range(0, 255);

            $display("\n# //--- Test %0d/%0d ---//", i + 1, NUM_TESTS);

            // <<<<< RESET và CẤU HÌNH lại từ đầu cho mỗi test case >>>>>
            presetn <= 0;
            #(CLK_PERIOD * 10);
            presetn <= 1;
            #(CLK_PERIOD * 2); // Đợi DUT ổn định sau reset
            apb_write(CFG_ADDR, 32'h00000003, 4'b0001); // Phải cấu hình lại vì reset đã xóa nó
            
            // 1. Gửi ký tự
            $display("# T=%0t [TB] TX: Sending char 0x%h ('%c')", $time, tx_char, tx_char);
            apb_write(TX_DATA_ADDR, {24'h0, tx_char}, 4'b0001);
            apb_write(CTRL_ADDR, 32'h1, 4'b0001);
            apb_write(CTRL_ADDR, 32'h0, 4'b0001);

            // 2. Đợi cho đến khi nhận xong
            do #(CLK_PERIOD * 50) apb_read(STT_ADDR);
            while (prdata[1] == 1'b0);
            
            // 3. Đọc ký tự và xóa cờ
            apb_read(RX_DATA_ADDR);
            rx_char = prdata[31:24];
            apb_write(STT_ADDR, 32'h2, 4'b0001); 

            $display("# T=%0t [TB] RX: Received char 0x%h ('%c')", $time, rx_char, rx_char);
            
            // 4. So sánh và báo cáo kết quả
            if (rx_char === tx_char) begin
                $display("# [TB] Result: PASSED");
                passed_count++;
            end else begin
                $error("# [TB] Result: FAILED! Sent 0x%h, but received 0x%h", tx_char, rx_char);
                failed_count++;
            end
        end

        // --- BÁO CÁO TỔNG KẾT CUỐI CÙNG ---
        $display("\n#");
        $display("# ============================================");
        $display("#      RANDOMIZED LOOPBACK TEST SUMMARY");
        $display("# ============================================");
        $display("#");
        $display("# Total Tests: %0d", NUM_TESTS);
        $display("# Passed:      %0d", passed_count);
        $display("# Failed:      %0d", failed_count);
        $display("#");
        if (failed_count == 0) begin
            $display("# RESULT: ALL LOOPBACK TESTS PASSED!");
        end else begin
            $display("# RESULT: TEST SUITE FAILED!");
        end
        $display("# ============================================");
        
        $finish;
    end

endmodule



