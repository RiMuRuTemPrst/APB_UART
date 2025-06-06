`timescale 1ns / 1ps

// Testbench for uart_top: TX -> RX Loopback Test
module uart_tb;

    parameter int CLK_FREQ_HZ = 50_000_000;
    parameter int BAUD_RATE   = 115200;
    
    parameter int CLK_PERIOD  = 20;

    // DUT Signals
    logic        clk;
    logic        rst_n;
    logic [7:0]  tx_data_in;
    logic [4:0]  cfg_reg_in;
    logic        start_tx_in;
    logic        cts_n_in;

    wire         tx_done_out;
    wire         rx_done_out;
    wire         parity_error_out;
    wire [7:0]   rx_data_out;
    wire         tx_busy_out;
    wire         rts_n_out;
    
    // The "Loopback Wire"
    wire         serial_line;

    // Instantiate the DUT
    uart_top #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE  (BAUD_RATE)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .tx_data_in(tx_data_in),
        .cfg_reg_in(cfg_reg_in),
        .start_tx_in(start_tx_in),
        .tx_done_out(tx_done_out),
        .rx_done_out(rx_done_out),
        .parity_error_out(parity_error_out),
        .rx_data_out(rx_data_out),
        .tx_busy_out(tx_busy_out),
        .cts_n_in(cts_n_in),
        .rts_n_out(rts_n_out),

        // Loopback Connection
        .txd_out(serial_line),
        .rxd_in(serial_line)
    );

    // Clock generator
    always #((CLK_PERIOD)/2) clk = ~clk;

    // Test Sequence
    initial begin
        clk <= 0;
        rst_n <= 0;
        cfg_reg_in <= 5'b00011; // Default to 8-N-1
        tx_data_in <= '0;
        start_tx_in <= 1'b0;
        cts_n_in <= 1'b0; // Assume receiver is always ready

        $display("T=%0t [TB] ====== Applying Reset ======", $time);
        #(CLK_PERIOD * 10);
        rst_n <= 1;
        $display("T=%0t [TB] ====== Reset Released, Starting Loopback Test ======", $time);
        #(CLK_PERIOD * 10);

        // --- Test Case: Send character 'U' (0x55) ---
        $display("\n[TB] --- Testing TX -> RX with character 'U' (0x55) ---");
        
        wait (tx_busy_out == 1'b0);
        @(posedge clk);
        
        $display("T=%0t [TB] TX is ready. Sending 'U'...", $time);
        tx_data_in <= 8'h55;
        start_tx_in <= 1'b1;
        @(posedge clk);
        start_tx_in <= 1'b0;

        $display("T=%0t [TB] TX initiated. Waiting for RX to report completion...", $time);
        wait (rx_done_out == 1'b1);

        $display("T=%0t [TB] RX has finished!", $time);
        
        #(CLK_PERIOD); // Wait one clock for data to be stable
        
        if (rx_data_out === 8'h55) begin
            $display("[TB] ---> PASSED! ✅  RX received 0x%h ('%c') as expected.", rx_data_out, rx_data_out);
        end else begin
            $display("[TB] ---> FAILED! ❌  RX received 0x%h, but expected 0x55.", rx_data_out);
        end

        #(CLK_PERIOD * 20);
        $display("\n\n[TB] ====== Loopback Test Finished ======");
        $finish;
    end

endmodule