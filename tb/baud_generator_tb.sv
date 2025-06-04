`timescale 1ns/1ps

module tb_uart_baud_rate_generator;
    //===========================================================================
    // Parameters (use same defaults as DUT)
    //===========================================================================
    localparam CLK_FREQ_HZ  = 50_000_000;    // 50 MHz
    localparam BAUD_RATE    = 115200;        // 115200 baud
    localparam DIVISOR      = CLK_FREQ_HZ / BAUD_RATE;  // ≈ 434
    localparam CLK_PERIOD_NS = 20;           // 20 ns ⇒ 50 MHz

    //===========================================================================
    // Testbench Signals
    //===========================================================================
    reg  clk;
    reg  rst_n;
    wire baud_tick;

    // Cycle counter to measure clock cycles between baud_tick pulses
    integer cycle_count;
    integer prev_tick_cycle;
    integer tick_count;

    //===========================================================================
    // Instantiate DUT
    //===========================================================================
    uart_baud_rate_generator #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE  (BAUD_RATE)
    ) dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .baud_tick(baud_tick)
    );

    //===========================================================================
    // Clock Generation: 50 MHz
    //===========================================================================
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD_NS/2) clk = ~clk;
    end

    //===========================================================================
    // Reset Sequence
    //===========================================================================
    initial begin
        rst_n = 1'b0;
        // Hold reset low for a few clock cycles
        repeat (5) @(posedge clk);
        rst_n = 1'b1;
    end

    //===========================================================================
    // Cycle Counter: increment on every rising clock edge
    //===========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cycle_count = 0;
        end else begin
            cycle_count = cycle_count + 1;
        end
    end

    //===========================================================================
    // Monitor baud_tick Pulses and Measure Period
    //===========================================================================
    initial begin
        // Initialize tracking variables
        prev_tick_cycle = 0;
        tick_count      = 0;

        // Wait for reset to be released
        @(posedge rst_n);
        @(posedge rst_n);

        $display("\n--- tb_uart_baud_rate_generator starting ---");
        $display("Expected DIVISOR = %0d cycles", DIVISOR);

        // Wait for first baud_tick after reset
        @(posedge baud_tick);
        prev_tick_cycle = cycle_count;
        tick_count = 1;
        $display("[%0t ns] First baud_tick detected at cycle %0d", $time, prev_tick_cycle);

        // Capture next 3 baud_tick pulses
        while (tick_count < 4) begin
            @(posedge baud_tick);
            tick_count = tick_count + 1;
            $display("[%0t ns] Baud_tick #%0d at cycle %0d; period = %0d cycles", 
                        $time, 
                        tick_count, 
                        cycle_count, 
                        cycle_count - prev_tick_cycle);
            prev_tick_cycle = cycle_count;
        end

        $display("--- Measured %0d baud_tick pulses, each ≈ %0d cycles apart ---\n", 
                    tick_count, 
                    DIVISOR);

        // Finish simulation
        #100;
        $finish;
    end

endmodule
