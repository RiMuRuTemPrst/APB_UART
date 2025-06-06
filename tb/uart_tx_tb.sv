`timescale 1ns / 1ps

module uart_tx_tb();

    // Tham số cho testbench
    parameter CLK_PERIOD = 5;  // 100MHz clock
    parameter BAUD_RATE = 115200;
    parameter CLK_PER_BIT = 100000000/BAUD_RATE; // Số chu kỳ clock cho 1 bit UART
    parameter MAX_BITS = 12;    // Số bit tối đa trong frame

    // Tín hiệu cho DUT (Device Under Test)
    reg clk;
    reg rst_n;
    reg baud_tick;
    reg tx_enable;
    reg [4:0] cfg_reg;
    reg [7:0] tx_data;
    
    wire tx;
    wire tx_busy;
    wire tx_done;
    
    // Bộ đếm để tạo baud_tick
    reg [15:0] baud_counter;
    
    // Khởi tạo UART TX module
    uart_tx DUT (
        .clk(clk),
        .rst_n(rst_n),
        .baud_tick(baud_tick),
        .tx_enable(tx_enable),
        .cfg_reg(cfg_reg),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy),
        .tx_done(tx_done)
    );
    
    // Tạo xung clock
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Tạo baud tick (cho tốc độ truyền)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            baud_counter <= 0;
            baud_tick <= 0;
        end else begin
            if (baud_counter >= CLK_PER_BIT - 1) begin
                baud_counter <= 0;
                baud_tick <= 1;
            end else begin
                baud_counter <= baud_counter + 1;
                baud_tick <= 0;
            end
        end
    end
    
    // Đếm các bit được truyền để xác thực
    integer bit_count;
    reg [MAX_BITS-1:0] received_data;
    
    // Task kiểm tra dữ liệu truyền
    task verify_transmission;
        input [7:0] data_to_send;
        input [4:0] cfg_to_use;
        input [MAX_BITS-1:0] expected_pkt;
        input integer expected_len;
        
        integer i;
        reg match;
        begin
            $display("Test: Sending data: %h with cfg: %b", data_to_send, cfg_to_use);
            
            // Đặt lại các thông số
            bit_count = 0;
            received_data = {MAX_BITS{1'b1}}; // Khởi tạo tất cả bits là 1
            
            // Kích hoạt truyền
            @(posedge clk);
            tx_data <= data_to_send;
            cfg_reg <= cfg_to_use;
            tx_enable <= 1;
            
            // Chờ cho đến khi bắt đầu truyền
            @(posedge clk);
            tx_enable <= 0;
            wait(tx_busy);
            
            // Giám sát đường truyền TX
            while (tx_busy) begin
                @(posedge baud_tick);
                received_data[bit_count] = tx;
                $display("  Bit %0d: %b", bit_count, tx);
                bit_count = bit_count + 1;
            end
            
            // Kiểm tra kết quả bằng cách so sánh từng bit
            match = 1'b1;
            for (i = 0; i < expected_len; i = i + 1) begin
                if (received_data[i] !== expected_pkt[i]) begin
                    match = 1'b0;
                end
            end
            
            // Hiển thị kết quả
            $display("  Received packet: %b", received_data);
            $display("  Expected packet: %b", expected_pkt);
            
            if (match) begin
                $display("  Test PASSED! Data correctly transmitted.");
            end else begin
                $display("  Test FAILED! Incorrect transmission.");
                // Hiển thị so sánh chi tiết
                for (i = 0; i < expected_len; i = i + 1) begin
                    if (received_data[i] !== expected_pkt[i]) begin
                        $display("    Bit %0d: Expected %b, Got %b", i, expected_pkt[i], received_data[i]);
                    end
                end
            end
            
            // Chờ cho đến khi tx_done
            wait(tx_done);
            $display("  Transaction completed. tx_done signal received.");
            
            // Thêm độ trễ giữa các lần kiểm tra
            repeat(5) @(posedge clk);
        end
    endtask
    
    // Khởi tạo các tín hiệu và chạy kiểm tra
    initial begin
        // Khởi tạo các tín hiệu
        rst_n = 0;
        tx_enable = 0;
        cfg_reg = 0;
        tx_data = 0;
        // Reset hệ thống
        #(CLK_PERIOD*5);
        rst_n = 1;
        #(CLK_PERIOD*5);
        
        $display("\n=== Starting UART TX Tests ===\n");
        
        // Test Case 1: 8-bit data, no parity, 1 stop bit (cfg_reg = 5'b00011)
        // Expected: Start bit (0) + 8 data bits + 1 stop bit (1)
        verify_transmission(
            8'hA5,                           // data: 10100101
            5'b00011,                        // cfg: 8-bit, no parity, 1 stop bit
            12'b110100101_0,                 // expected: stopBit + data + startBit (right to left)
            10                               // expected length: 10 bits
        );

        // Test Case 2: 7-bit data, even parity, 1 stop bit (cfg_reg = 5'b01010)
        // Expected: Start bit (0) + 7 data bits + even parity + 1 stop bit (1)
        verify_transmission(
            8'h53,                           // data: 01010011 (7-bit: 1010011)
            5'b01010,                        // cfg: 7-bit, even parity, 1 stop bit
            12'b1_0_1010011_0,               // expected: stopBit + evenParity + data + startBit
            10                               // expected length: 10 bits
        );

        // Test Case 3: 8-bit data, odd parity, 2 stop bits (cfg_reg = 5'b11011)
        // Expected: Start bit (0) + 8 data bits + odd parity + 2 stop bits (11)
        verify_transmission(
            8'h3C,                           // data: 00111100
            5'b11011,                        // cfg: 8-bit, odd parity, 2 stop bits
            12'b11_1_00111100_0,             // expected: 2stopBits + oddParity + data + startBit
            12                               // expected length: 12 bits
        );

        // Test Case 4: 5-bit data, no parity, 2 stop bits (cfg_reg = 5'b01000)
        // Expected: Start bit (0) + 5 data bits + 2 stop bits (11)
        verify_transmission(
            8'h0F,                           // data: 00001111 (5-bit: 01111)
            5'b01000,                        // cfg: 5-bit, no parity, 2 stop bits
            12'b11_01111_0,                  // expected: 2stopBits + data + startBit
            8                                // expected length: 8 bits
        );
        
        // Test Case 5: 6-bit data, odd parity, 1 stop bit (cfg_reg = 5'b10001)
        // Expected: Start bit (0) + 6 data bits + odd parity + 1 stop bit (1)
        verify_transmission(
            8'h2A,                           // data: 00101010 (6-bit: 101010)
            5'b10001,                        // cfg: 6-bit, odd parity, 1 stop bit
            12'b1_0_101010_0,                // expected: stopBit + oddParity + data + startBit
            9                                // expected length: 9 bits
        );
        
        $display("\n=== UART TX Tests Completed ===\n");
        
        // Kết thúc mô phỏng
        #(CLK_PERIOD*50);
        $finish;
    end
    
    // Tùy chọn tạo file VCD để xem dạng sóng nếu cần
    // initial begin
    //     $dumpfile("uart_tx_tb.vcd");
    //     $dumpvars(0, uart_tx_tb);
    // end

endmodule