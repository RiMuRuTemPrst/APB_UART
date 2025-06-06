`timescale 1ns / 1ps

module apb_interface_register_block_tb;

    //===============================================================================
    // Parameters and Signals
    //===============================================================================
    parameter CLK_PERIOD = 20; // 50 MHz
    parameter NUM_TESTS = 1000;

    localparam TX_DATA_ADDR = 13'h000;
    localparam CFG_ADDR     = 13'h008;
    localparam CTRL_ADDR    = 13'h00C;

    // Test counters
    integer passed_count = 0;
    integer failed_count = 0;

    reg        pclk;
    reg        presetn;
    reg        psel;
    reg        penable;
    reg        pwrite;
    reg [12:0] paddr;
    reg [31:0] pwdata;
    reg [3:0]  pstrb;
    
    // Unused inputs for this test, tied to 0
    reg        set_tx_done = 0;
    reg        set_rx_done = 0;
    reg        set_parity_error = 0;
    reg [7:0]  rx_data_in = 0;

    wire       pready;
    wire [31:0] prdata;
    wire       pslverr;
    wire [7:0] tx_data_out;
    wire       start_tx;
    wire [4:0] cfg_reg_out;

    // Instantiate the DUT
    apb_interface_register_block_top dut (
        .pclk(pclk), .presetn(presetn), .psel(psel), .penable(penable), .pwrite(pwrite),
        .paddr(paddr), .pwdata(pwdata), .pstrb(pstrb), .pready(pready), .prdata(prdata),
        .pslverr(pslverr), .set_tx_done(set_tx_done), .set_rx_done(set_rx_done),
        .set_parity_error(set_parity_error), .rx_data_in(rx_data_in),
        .tx_data_out(tx_data_out), .start_tx(start_tx), .cfg_reg_out(cfg_reg_out)
    );

    // Clock generator
    always #((CLK_PERIOD)/2) pclk = ~pclk;

    // Reusable APB Write Task
    task apb_write(input [12:0] address, input [31:0] data, input [3:0] strobe);
        begin
            // SETUP Phase
            psel <= 1'b1;
            paddr <= address;
            pwrite <= 1'b1;
            pwdata <= data;
            pstrb  <= strobe;
            @(posedge pclk);
            // ACCESS Phase
            penable <= 1'b1;
            wait (pready == 1'b1);
            @(posedge pclk);
            // End transaction
            psel <= 1'b0;
            penable <= 1'b0;
        end
    endtask

    //===============================================================================
    // Main Test Sequence
    //===============================================================================
    initial begin
        // Initialization and Reset
        pclk <= 0; presetn <= 0; psel <= 0; penable <= 0; pwrite <= 0;
        paddr <= 13'h0; pwdata <= 32'h0; pstrb <= 4'h0;
        $display("T=%0t [TB] ====== Applying Reset ======", $time);
        #(CLK_PERIOD * 5);
        presetn <= 1;
        $display("T=%0t [TB] ====== Reset Released, Starting Comprehensive Randomized Tests ======", $time);
        @(posedge pclk);

        //-----------------------------------------------------------------------
        // Randomized Test Loop for Multiple Registers
        //-----------------------------------------------------------------------
        $display("[TB] Running %0d randomized tests on CFG_REG, TX_DATA_REG, and CTRL_REG...", NUM_TESTS);
        for (integer i = 0; i < NUM_TESTS; i = i + 1) begin
            logic [12:0] selected_addr;
            logic [31:0] random_wdata;
            logic [3:0]  strobe;
            integer      choice;

            // Step 1: Randomly choose which register to test
            choice = $urandom_range(2, 0); // Generates a number: 0, 1, or 2

            case (choice)
                // Case 0: Test CFG_REG
                0: begin
                    selected_addr = CFG_ADDR;
                    random_wdata = {$random}; // Full 32-bit random data
                    strobe = 4'b0001;          // Only write to the lowest byte for CFG
                end
                // Case 1: Test TX_DATA_REG
                1: begin
                    selected_addr = TX_DATA_ADDR;
                    random_wdata = {$random};
                    strobe = 4'b1111;          // Write to all 4 bytes
                end
                // Case 2: Test CTRL_REG
                2: begin
                    selected_addr = CTRL_ADDR;
                    random_wdata = {$random} % 2; // Data will be 0 or 1
                    strobe = 4'b0001;          // Only write to the lowest byte for CTRL
                end
            endcase
            
            // Step 2: Perform the APB write
            apb_write(selected_addr, random_wdata, strobe);

            // Step 3: Wait and Verify
            #(CLK_PERIOD);
            
            case (choice)
                // Verify CFG_REG
                0: begin
                    if (cfg_reg_out === random_wdata[4:0]) begin
                        passed_count++;
                    end else begin
                        failed_count++;
                    end
                end
                // Verify TX_DATA_REG
                1: begin
                    if (tx_data_out === random_wdata[7:0]) begin
                        passed_count++;
                    end else begin
                        failed_count++;
                    end
                end
                // Verify CTRL_REG
                2: begin
                    if (start_tx === random_wdata[0]) begin
                        passed_count++;
                    end else begin
                        failed_count++;
                    end
                end
            endcase
        end

        //-----------------------------------------------------------------------
        // Final Results
        //-----------------------------------------------------------------------
        $display("\n\n=========================================================");
        $display("           RANDOMIZED TEST SUMMARY");
        $display("=========================================================");
        $display("Total Tests: %0d", NUM_TESTS);
        $display("Passed:      %0d", passed_count);
        $display("Failed:      %0d", failed_count);
        if (failed_count == 0) begin
            $display("\nRESULT: ALL TESTS PASSED! ✅");
        end else begin
            $display("\nRESULT: SOME TESTS FAILED! ❌");
        end
        $display("=========================================================");
        
        #(CLK_PERIOD * 5);
        $finish;
    end
endmodule