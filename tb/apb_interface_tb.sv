`timescale 1ns/1ps

module apb_interface_tb;

    // Clock and Reset
    logic pclk;
    logic presetn;

    // APB signals
    logic psel = 1;
    logic penable, pwrite;
    logic [12:0] paddr;
    logic [31:0] pwdata;
    logic [3:0] pstrb;
    logic [31:0] prdata;
    logic pready, pslverr;

    // Register interface
    logic [4:0] reg_address_des;
    logic [7:0] data_write_to_reg;
    logic start_tx_signal;

    logic [7:0] rx_data_in;
    logic tx_done_signal, rx_done_signal, parity_error_signal;

    always #10 pclk = ~pclk;

    apb_interface #(.TIMEOUT_CYCLES(20)) dut (
        .pclk(pclk), .presetn(presetn), .psel(psel), .penable(penable),
        .pwrite(pwrite), .paddr(paddr), .pwdata(pwdata), .pstrb(pstrb),
        .pready(pready), .prdata(prdata), .pslverr(pslverr),
        .reg_address_des(reg_address_des), .data_write_to_reg(data_write_to_reg),
        .start_tx_signal(start_tx_signal), .rx_data_in(rx_data_in),
        .tx_done_signal(tx_done_signal), .rx_done_signal(rx_done_signal),
        .parity_error_signal(parity_error_signal)
    );

    // Write task
    task automatic apb_write(input [12:0] addr, input [31:0] data, input [3:0] strb);
        @(posedge pclk);
        paddr = addr; pwdata = data; pstrb = strb;
        pwrite = 1; penable = 0;
        @(posedge pclk);
        penable = 1;
        wait(pready);
        @(posedge pclk);
        penable = 0;
    endtask

    // Read task
    task automatic apb_read(input [12:0] addr);
        @(posedge pclk);
        paddr = addr;
        pwrite = 0; penable = 0;
        @(posedge pclk);
        penable = 1;
        wait(pready);
        @(posedge pclk);
        $display("READ [0x%04h] => 0x%08x | pslverr: %b", addr, prdata, pslverr);
        penable = 0;
    endtask

    // Reset + Watchdog
    initial begin
        pclk = 0;
        presetn = 0;
        penable = 0;
        pwrite = 0;
        paddr = 0;
        pwdata = 0;
        pstrb = 4'b0000;
        rx_data_in = 8'h00;
        tx_done_signal = 0;
        rx_done_signal = 0;
        parity_error_signal = 0;

        #20;
        @(posedge pclk); presetn = 1;
    end

    initial begin
        wait(presetn); @(posedge pclk);

        // 1. Đọc / Ghi cfg_reg (0x0008)
        $display("\n--- [1] GHI & ĐỌC cfg_reg ---");
        apb_write(13'h0008, 32'h00000055, 4'b0001);
        tx_done_signal = 1; @(posedge pclk); tx_done_signal = 0;
        apb_read(13'h0008);

        // 2. Đọc / Ghi ctrl_reg (0x000C)
        $display("\n--- [2] GHI & ĐỌC ctrl_reg ---");
        apb_write(13'h000C, 32'h00000001, 4'b0001);
        tx_done_signal = 1; @(posedge pclk); tx_done_signal = 0;
        apb_read(13'h000C);

        // 3. Đọc stt_reg (0x0010)
        $display("\n--- [3] ĐỌC stt_reg ---");
        rx_data_in = 8'hAA;
        apb_read(13'h0010);

        // 4. Ghi & Đọc tx_data_reg (0x0000) – full 4 bytes
        $display("\n--- [4] GHI & ĐỌC tx_data_reg (4 byte) ---");
        apb_write(13'h0000, 32'hA1B2C3D4, 4'b1111);
        repeat (4) begin
            tx_done_signal = 1;
            @(posedge pclk);
            tx_done_signal = 0;
            @(posedge pclk);
        end
        apb_read(13'h0000);  // read after write (if supported)

        // 5. Đọc đủ 4 byte từ rx_data_reg (0x0004)
        $display("\n--- [5] ĐỌC 4 BYTE từ rx_data_reg ---");
        for (int i = 0; i < 4; i++) begin
            rx_data_in = 8'hA0 + i;
            rx_done_signal = 1;
            @(posedge pclk);
            rx_done_signal = 0;
        end
        apb_read(13'h0004);

        // Kết thúc
        $display("\n✅ Đã hoàn tất tất cả các kiểm thử!");
        #100;
        $finish;
    end

    initial begin
        #1_000_000;
        $display("⚠️ TIMEOUT: Mô phỏng chạy quá lâu!");
        $finish;
    end

endmodule
