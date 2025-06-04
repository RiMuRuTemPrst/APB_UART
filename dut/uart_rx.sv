`timescale 1ns / 1ps

module uart_rx (
    input              clk,
    input              rst_n,
    input              baud_tick,
    input              rx,
    input      [4:0]   cfg_reg,    // [1:0]=data_bits, [2]=stop_bits, [3]=parity_en, [4]=parity_type

    output reg [7:0]   rx_data,
    output reg         rx_done,
    output reg         parity_error
);

    // FSM states
    localparam  IDLE       = 3'd0,
                START_BIT  = 3'd1,
                DATA_BITS  = 3'd2,
                PARITY_BIT = 3'd3,
                STOP_BITS  = 3'd4;

    // Internal registers
    reg [2:0] state;
    reg [3:0] bit_counter;
    reg [7:0] rx_shift;
    reg       parity_calc;

    // Decode config
    wire [1:0] data_bits_cfg = cfg_reg[1:0];
    wire       stop_bits_cfg = cfg_reg[2];
    wire       parity_en     = cfg_reg[3];
    wire       parity_type   = cfg_reg[4];

    // Derived lengths
    wire [3:0] data_bits_len = (data_bits_cfg==2'b00)?5:
                                (data_bits_cfg==2'b01)?6:
                                (data_bits_cfg==2'b10)?7:8;
    wire [1:0] stop_bits_len = stop_bits_cfg ? 2 : 1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= IDLE;
            rx_data      <= 8'd0;
            rx_done      <= 1'b0;
            parity_error <= 1'b0;
            rx_shift     <= 8'd0;
            bit_counter  <= 4'd0;
            parity_calc  <= 1'b0;
        end else begin
            // default clear rx_done
            rx_done <= 1'b0;

            case (state)
                IDLE: begin
                    bit_counter  <= 4'd0;
                    parity_calc  <= 1'b0;
                    rx_shift     <= 8'd0;     // clear shift register
                    parity_error <= 1'b0;
                    if (!rx) begin
                        state <= START_BIT;
                    end
                end

                START_BIT: begin
                    if (baud_tick) begin
                        // validate start bit low
                        if (!rx) begin
                            bit_counter <= 4'd0;
                            state       <= DATA_BITS;
                        end else begin
                            state <= IDLE;
                        end
                    end
                end

                DATA_BITS: begin
                    if (baud_tick) begin
                        // Store sampled bit into position bit_counter (LSB-first)
                        rx_shift[bit_counter] <= rx;
                        parity_calc <= parity_calc ^ rx;
                        if (bit_counter < data_bits_len - 1) begin
                            bit_counter <= bit_counter + 1'b1;
                        end else begin
                            bit_counter <= 4'd0;
                            state       <= parity_en ? PARITY_BIT : STOP_BITS;
                        end
                    end
                end

                PARITY_BIT: begin
                    if (baud_tick) begin
                        // Check parity: even -> 0, odd -> 1
                        parity_error <= ((parity_calc ^ rx) != parity_type);
                        state <= STOP_BITS;
                    end
                end

                STOP_BITS: begin
                    if (baud_tick) begin
                        if (bit_counter < stop_bits_len - 1) begin
                            bit_counter <= bit_counter + 1'b1;
                        end else begin
                            // On final stop-bit sample, output data and flag done
                            rx_data  <= rx_shift;   // LSB-first already correct, upper bits zero
                            rx_done  <= 1'b1;
                            state    <= IDLE;
                        end
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
