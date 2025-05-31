`timescale 1ns/1ps

module tb_apb_uart_top;

    // Clock and reset
    reg clk, rst_n;
    reg pclk, presetn;

    // APB interface
    reg         psel, penable, pwrite;
    reg [12:0]  paddr;
    reg [31:0]  pwdata;
    reg [3:0]   pstrb;
    wire [31:0] prdata;
    wire        pslverr, pready;

    // UART physical
    reg         rx;
    reg         cts_n;
    wire        tx;
    wire        rts_n;

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50MHz
    end

    initial begin
        pclk = 0;
        forever #10 pclk = ~pclk; // same as clk
    end

    // Instantiate DUT
    apb_uart_top dut (
        .clk(clk),
        .rst_n(rst_n),

        .pclk(pclk),
        .presetn(presetn),
        .psel(psel),
        .penable(penable),
        .pwrite(pwrite),
        .paddr(paddr),
        .pwdata(pwdata),
        .pstrb(pstrb),
        .prdata(prdata),
        .pslverr(pslverr),
        .pready(pready),

        .rx(rx),
        .cts_n(cts_n),
        .tx(tx),
        .rts_n(rts_n)
    );

    // Task: APB write
    task apb_write(input [12:0] addr, input [31:0] data, input [3:0] strb = 4'hF);
        begin
            @(posedge pclk);
            paddr   = addr;
            pwdata  = data;
            pwrite  = 1;
            psel    = 1;
            pstrb   = strb;
            penable = 0;

            @(posedge pclk);
            penable = 1;
            wait (pready);
            @(posedge pclk);
            psel    = 0;
            penable = 0;
        end
    endtask

    // Task: APB read
    task apb_read(input [12:0] addr);
        begin
            @(posedge pclk);
            paddr   = addr;
            pwrite  = 0;
            psel    = 1;
            penable = 0;
            pstrb   = 4'hF;

            @(posedge pclk);
            penable = 1;
            wait (pready);
            @(posedge pclk);
            $display("Read[0x%04h] => 0x%08h", addr, prdata);
            psel    = 0;
            penable = 0;
        end
    endtask

    // Test procedure
    initial begin
        // Initial states
        psel    = 0; penable = 0; pwrite = 0;
        paddr   = 0; pwdata = 0; pstrb = 4'hF;
        rst_n   = 0; presetn = 0; rx = 1; cts_n = 1;

        #100;
        rst_n   = 1;
        presetn = 1;
        cts_n   = 0;

        // ======================
        // Test 1: Write config
        // ======================
        $display("Write CFG register: 8 data bits, 1 stop, no parity");
        apb_write(13'h008, 32'h0F); // cfg_reg: 1111b = 8bit, 1 stop, parity odd+enabled

        // ======================
        // Test 2: Write TX data
        // ======================
        $display("Write TX data: 0xAB");
        apb_write(13'h000, 32'h000000AB);

        // ======================
        // Test 3: Start TX
        // ======================
        $display("Start transmission");
        apb_write(13'h00C, 32'h1);

        // Wait some time for TX to finish
        #200_000;

        // ======================
        // Test 4: Read Status Reg
        // ======================
        $display("Read STT register");
        apb_read(13'h010);

        // ======================
        // Test 5: Simulate RX
        // ======================
        $display("Simulate UART RX of 0x55");
        simulate_rx_byte(8'h55);

        // Wait for RX
        #200_000;

        // ======================
        // Test 6: Read RX Data
        // ======================
        apb_read(13'h004); // RX data

        #100;
        $finish;
    end

    // Simulate UART RX logic: send 1 start + 8 data + 1 stop
    task simulate_rx_byte(input [7:0] data);
        integer i;
        begin
            rx = 0; // Start bit
            #(8680); // 1 bit at 115200 baud (1/115200 ≈ 8680ns)

            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                #(8680);
            end

            rx = 1; // Stop bit
            #(8680);
        end
    endtask

endmodule
