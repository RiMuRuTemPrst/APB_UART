`timescale 1ns / 1ps

// Testbench for uart_top: 1000 Randomized TX -> RX Loopback Tests with Verbose Logging
module uart_tb;

    //===============================================================================
    // Parameters
    //===============================================================================
    parameter int CLK_FREQ_HZ = 50_000_000;
    parameter int BAUD_RATE   = 115200;
    
    parameter int CLK_PERIOD  = 20;
    parameter int NUM_TESTS   = 1000;

    // Test counters
    integer passed_count = 0;
    integer failed_count = 0;

    //===============================================================================
    // Signals
    //===============================================================================
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
    
    wire         serial_line;

    //===============================================================================
    // DUT Instantiation
    //===============================================================================
    uart_top #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE  (BAUD_RATE)
    ) dut (
        .clk(clk), .rst_n(rst_n), .tx_data_in(tx_data_in), .cfg_reg_in(cfg_reg_in),
        .start_tx_in(start_tx_in), .tx_done_out(tx_done_out), .rx_done_out(rx_done_out),
        .parity_error_out(parity_error_out), .rx_data_out(rx_data_out),
        .tx_busy_out(tx_busy_out), .cts_n_in(cts_n_in), .rts_n_out(rts_n_out),
        .txd_out(serial_line), .rxd_in(serial_line)
    );

    // Clock generator
    always #((CLK_PERIOD)/2) clk = ~clk;

    //===============================================================================
    // Main Test Sequence
    //===============================================================================
    initial begin
        clk <= 0; rst_n <= 0;
        cfg_reg_in <= 5'b00011; // 8-N-1
        tx_data_in <= '0; start_tx_in <= 1'b0; cts_n_in <= 1'b0;

        $display("T=%0t [TB] ====== Applying Reset ======", $time);
        #(CLK_PERIOD * 10);
        rst_n <= 1;
        $display("T=%0t [TB] ====== Reset Released, Starting Randomized Loopback Test ======", $time);
        #(CLK_PERIOD * 10);
        
        // --- Randomized Test Loop ---
        $display("[TB] Running %0d randomized loopback tests with verbose logging...", NUM_TESTS);

        for (integer i = 0; i < NUM_TESTS; i = i + 1) begin
            logic [7:0] rand_data;
            $display("\n//--- Test %0d/%0d ---//", i + 1, NUM_TESTS);

            // 1. Generate random character
            rand_data = $random;
            
            // 2. Wait for TX to be ready
            wait (tx_busy_out == 1'b0);
            @(posedge clk);
            
            // 3. Send the character
            $display("T=%0t [TB] TX: Sending char 0x%h ('%c')", $time, rand_data, rand_data);
            tx_data_in <= rand_data;
            start_tx_in <= 1'b1;
            @(posedge clk);
            start_tx_in <= 1'b0;
            
            // 4. Wait for RX to complete
            wait (rx_done_out == 1'b1);
            
            // 5. Verify the received data
            #(CLK_PERIOD); // Wait one clock for data to be stable
            
            $display("T=%0t [TB] RX: Received char 0x%h ('%c')", $time, rx_data_out, rx_data_out);

            if (rx_data_out === rand_data) begin
                passed_count++;
                $display("[TB] Result: PASSED ");
            end else begin
                failed_count++;
                $error("[TB] Result: FAILED ");
            end
        end

        // --- Final Results ---
        $display("\n\n=========================================================");
        $display("          RANDOMIZED LOOPBACK TEST SUMMARY");
        $display("=========================================================");
        $display("Total Tests: %0d", NUM_TESTS);
        $display("Passed:      %0d", passed_count);
        $display("Failed:      %0d", failed_count);
        if (failed_count == 0) begin
            $display("\nRESULT: ALL LOOPBACK TESTS PASSED!");
        end else begin
            $display("\nRESULT: LOOPBACK TESTS FAILED!");
        end
        $display("=========================================================");
        
        #(CLK_PERIOD * 20);
        $finish;
    end

endmodule