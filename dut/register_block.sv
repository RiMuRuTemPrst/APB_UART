module register_block (
    // APB interface signals
    input             pclk,              // APB clock
    input             presetn,           // APB reset, active LOW
    input             psel,              // APB select
    input             penable,           // APB enable
    input             pwrite,            // APB write
    input             pslverr,           // APB slave error

    input wire  [4:0]  reg_address_des,          // Register address to access
    input wire  [7:0]  data_write_to_reg,       // Data to write to register
    input wire         start_tx_signal,

    output reg [7:0]  data_to_APB,          // data trasnfer to APB
    output reg        tx_done_signal,      // Signal to indicate TX done
    output reg        rx_done_signal,      // Signal to indicate RX done
    output reg        parity_error_signal,  // Signal to indicate parity error
    // UART TX/RX Interface
    input             set_tx_done,
    input             set_rx_done,
    input             set_parity_error,
    input      [7:0]  rx_data_in,
    output reg [7:0]  tx_data_out,
    output reg        start_tx,
    output reg [4:0]  cfg_reg_out
);

    //===============================================================================
    // INTERNAL REGISTERS
    //===============================================================================
    reg [31:0] tx_data_reg;
    reg [31:0] rx_data_reg;
    reg [31:0] cfg_reg;
    reg [31:0] ctrl_reg;
    reg [31:0] stt_reg;

    //===============================================================================
    // Address map constants
    //===============================================================================
    localparam TX_DATA_ADDR = 13'h000;
    localparam RX_DATA_ADDR = 13'h004;
    localparam CFG_ADDR     = 13'h008;
    localparam CTRL_ADDR    = 13'h00C;
    localparam STT_ADDR     = 13'h010;

    //===============================================================================
    // APB Handle
    //===============================================================================
    always @(posedge pclk or negedge presetn) 
    begin
        if (!presetn) 
        begin
            tx_data_reg    <= 32'd0;
            rx_data_reg    <= 32'd0;
            cfg_reg        <= 32'd0;
            ctrl_reg       <= 32'd0;
            stt_reg        <= 32'd0;
            data_to_APB    <= 32'd0;
            tx_done_signal <= 1'b0;
            rx_done_signal <= 1'b0;
            parity_error_signal <= 1'b0;
        end 
        else 
        begin
            rx_done_signal <= stt_reg[1];
            parity_error_signal <= stt_reg[2];
            tx_done_signal <= stt_reg[0];

            if (pslverr) 
            begin
                tx_data_reg   <= tx_data_reg;
                rx_data_reg   <= rx_data_reg;
                cfg_reg       <= cfg_reg;
                ctrl_reg      <= ctrl_reg;
                stt_reg       <= stt_reg;
            end 
            else 
            begin
                if (pwrite) 
                begin
                    ctrl_reg[0] <= start_tx_signal;
                    data_to_APB <= 8'd0;
                    case (reg_address_des)
                        TX_DATA_ADDR: begin
                            tx_data_reg[7:0] <= data_write_to_reg[7:0];
                        end
                        CFG_ADDR: begin
                            cfg_reg[4:0] <= data_write_to_reg[4:0];
                        end
                        CTRL_ADDR: begin
                            ctrl_reg[0] <= data_write_to_reg[0];
                        end
                        default: begin 
                            tx_data_reg   <= tx_data_reg;
                            rx_data_reg   <= rx_data_reg;
                            ctrl_reg      <= ctrl_reg;
                            cfg_reg       <= cfg_reg;
                            stt_reg       <= stt_reg;
                        end
                    endcase
                end 
                else 
                begin
                    tx_data_reg   <= tx_data_reg;
                    case (reg_address_des)
                        TX_DATA_ADDR: data_to_APB <= tx_data_reg[7:0];
                        RX_DATA_ADDR: data_to_APB <= rx_data_reg[7:0];
                        CFG_ADDR:     data_to_APB <= cfg_reg[4:0];
                        CTRL_ADDR:    data_to_APB <= ctrl_reg[0];
                        STT_ADDR:     data_to_APB <= stt_reg[7:0];
                        default: begin
                            data_to_APB <= 8'b0;
                        end
                    endcase
                end
            end

            stt_reg[0] <= set_tx_done;
            stt_reg[1] <= set_rx_done;
            stt_reg[2] <= set_parity_error;
            rx_data_reg[7:0] <= rx_data_in;
        end
    end

    //===============================================================================
    // UART logic outputs
    //===============================================================================
    always @(posedge pclk or negedge presetn) 
    begin
        if (!presetn) 
        begin
            tx_data_out       <= 8'd0;
            start_tx          <= 1'b0;
            cfg_reg_out       <= 5'd0;
        end 
        else 
        begin
            tx_data_out       <= tx_data_reg[7:0];
            start_tx          <= ctrl_reg[0];
            cfg_reg_out       <= cfg_reg[4:0];
        end
    end

endmodule
