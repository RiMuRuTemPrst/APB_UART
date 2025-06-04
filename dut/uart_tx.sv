`timescale 1ns / 1ps

module uart_tx (
    input              clk,
    input              rst_n,
    input              baud_tick,
    input              tx_enable,
    input      [4:0]   cfg_reg,
    input      [7:0]   tx_data,

    output reg         tx,
    output reg         tx_busy,
    output reg         tx_done
);

    localparam  IDLE        = 3'd0,
                START_BIT   = 3'd1,
                DATA_BITS   = 3'd2,
                PARITY_BIT  = 3'd3,
                STOP_BITS   = 3'd4;

    reg [2:0] state;
    reg [3:0] bit_counter;
    reg [7:0] tx_data_reg;
    reg [4:0] cfg_reg_reg;

    // Configuration bits
    wire [1:0] data_bits_cfg = cfg_reg_reg[1:0];   // Data bits configuration
    wire stop_bits_cfg       = cfg_reg_reg[2];     // Stop bits configuration
    wire parity_en           = cfg_reg_reg[3];     // Parity enable
    wire parity_type         = cfg_reg_reg[4];     // 0: Even, 1: Odd

    // Lengths
    wire [3:0] data_bits_len = data_bits_cfg + 4'd5;
    wire [1:0] stop_bits_len = stop_bits_cfg ? 2'd2 : 2'd1;

    // Parity bit (registered)
    reg parity_bit;

    // ✅ Load data & config & compute parity bit
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_data_reg <= 8'd0;
            cfg_reg_reg <= 5'd0;
            parity_bit  <= 1'b0;
        end else if (tx_enable && state == IDLE) begin
            tx_data_reg <= tx_data;
            cfg_reg_reg <= cfg_reg;
            case (cfg_reg[1:0])
                2'b00: parity_bit <= cfg_reg[4] ? !(^tx_data[4:0]) : ^tx_data[4:0]; // 5 bits
                2'b01: parity_bit <= cfg_reg[4] ? !(^tx_data[5:0]) : ^tx_data[5:0]; // 6 bits
                2'b10: parity_bit <= cfg_reg[4] ? !(^tx_data[6:0]) : ^tx_data[6:0]; // 7 bits
                2'b11: parity_bit <= cfg_reg[4] ? !(^tx_data[7:0]) : ^tx_data[7:0]; // 8 bits
            endcase
        end
    end

    // UART transmission state machine
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            tx         <= 1'b1;
            tx_busy    <= 1'b0;
            tx_done    <= 1'b1;
            bit_counter <= 4'd0;
        end else begin
            case (state)
                IDLE: begin
                    tx         <= 1'b1;
                    tx_done    <= 1'b1;
                    bit_counter <= 4'd0;

                    if (tx_enable) 
                    begin
                        tx_busy <= 1'b1;
                        tx_done <= 1'b0;
                        state   <= START_BIT;
                    end else 
                    begin
                        tx_busy <= 1'b0;
                        tx_done <= 1'b1;
                    end
                end

                START_BIT: begin
                    tx <= 1'b0;  // Start bit

                    if (baud_tick) begin
                        state <= DATA_BITS;
                        bit_counter <= 4'd0;
                    end
                end

                DATA_BITS: begin
                    tx <= tx_data_reg[bit_counter];  // Transmit LSB first

                    if (baud_tick) begin
                        if (bit_counter < data_bits_len - 1) begin
                            bit_counter <= bit_counter + 1;
                        end else begin
                            bit_counter <= 4'd0;
                            state <= parity_en ? PARITY_BIT : STOP_BITS;
                        end
                    end
                end

                PARITY_BIT: begin
                    tx <= parity_bit;

                    if (baud_tick) begin
                        state <= STOP_BITS;
                        bit_counter <= 4'd0;
                    end
                end

                STOP_BITS: begin
                    tx <= 1'b1;  // Stop bit is high

                    if (baud_tick) begin
                        if (bit_counter < stop_bits_len - 1) begin
                            bit_counter <= bit_counter + 1;
                        end else begin
                            tx_done  <= 1'b1;
                            tx_busy  <= 1'b0;
                            state    <= IDLE;
                        end
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule