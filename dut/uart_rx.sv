`timescale 1ns / 1ps

// UART Receiver, final architecture based on reference code.
// Uses a more robust start bit validation method.
module uart_rx #(
    parameter int CLK_FREQ_HZ = 50_000_000,
    parameter int BAUD_RATE   = 115200
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        rx,
    input  logic [4:0]  cfg_reg,

    output logic [7:0]   rx_data,
    output logic         rx_done,
    output logic         parity_error
);

    // FSM states
    typedef enum logic [1:0] {
        STATE_IDLE,
        STATE_START_VALIDATE,
        STATE_RECEIVE_DATA,
        STATE_RECEIVE_STOP
    } state_t;

    state_t state;
                
    localparam int OVERSAMPLE_RATE = 16;
    localparam int DIVISOR = CLK_FREQ_HZ / (BAUD_RATE * OVERSAMPLE_RATE);

    // Internal registers
    logic [$clog2(OVERSAMPLE_RATE):0] sample_counter;
    logic [2:0]                       bit_counter;
    logic [7:0]                       rx_shift_reg;
    
    // Input Synchronizer
    logic rx_s1, rx_s2;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) {rx_s1, rx_s2} <= 2'b11;
        else        {rx_s1, rx_s2} <= {rx, rx_s1};
    end
    wire rx_sync = rx_s2;

    // Free-running Oversampling Tick Generator
    logic [$clog2(DIVISOR)-1:0] tick_counter;
    logic sample_tick;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)                   tick_counter <= '0;
        else if (tick_counter == DIVISOR - 1) tick_counter <= '0;
        else                          tick_counter <= tick_counter + 1;
    end
    assign sample_tick = (tick_counter == DIVISOR - 1);

    // Main FSM and Datapath Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state          <= STATE_IDLE;
            sample_counter <= '0;
            bit_counter    <= '0;
            rx_shift_reg   <= '0;
            rx_data        <= '0;
            rx_done        <= 1'b0;
            parity_error   <= 1'b0; // Parity not implemented in this version for simplicity
        end else begin
            if (rx_done) rx_done <= 1'b0;

            // FSM is driven by the fast sampling tick
            if (sample_tick) begin
                case (state)
                    STATE_IDLE: begin
                        // At every sample tick, check if the line is low.
                        if (!rx_sync) begin
                            state          <= STATE_START_VALIDATE;
                            // Start counting to see if it's a real start bit
                            sample_counter <= 1;
                        end
                    end

                    STATE_START_VALIDATE: begin
                        // If the line is still low, keep counting.
                        if (!rx_sync) begin
                            // If we have seen a low for half a bit period, it's a valid start.
                            if (sample_counter == OVERSAMPLE_RATE / 2) begin
                                state          <= STATE_RECEIVE_DATA;
                                // Reload counter to wait for the next full bit period
                                sample_counter <= OVERSAMPLE_RATE;
                                bit_counter    <= 0;
                            end else begin
                                sample_counter <= sample_counter + 1;
                            end
                        end else begin
                            // Glitch, not a real start bit. Go back to idle.
                            state          <= STATE_IDLE;
                            sample_counter <= 0;
                        end
                    end

                    STATE_RECEIVE_DATA: begin
                        sample_counter <= sample_counter - 1;
                        if (sample_counter == 1) begin
                            // We are at the middle of a data bit. Sample it.
                            rx_shift_reg[bit_counter] <= rx_sync;
                            
                            // Reload counter for the next bit
                            sample_counter <= OVERSAMPLE_RATE;
                            
                            // Assuming 8 data bits (can be parameterized from cfg_reg)
                            if (bit_counter == 7) begin
                                state <= STATE_RECEIVE_STOP;
                            end else begin
                                bit_counter <= bit_counter + 1;
                            end
                        end
                    end

                    STATE_RECEIVE_STOP: begin
                        sample_counter <= sample_counter - 1;
                        if (sample_counter == 1) begin
                            // We are at the middle of the stop bit.
                            if (rx_sync) begin // Stop bit must be high
                                rx_data <= rx_shift_reg;
                                rx_done <= 1'b1;
                            end else begin
                                // Framing error
                            end
                            // Frame is finished, return to idle
                            state <= STATE_IDLE;
                        end
                    end
                endcase
            end
        end
    end
endmodule