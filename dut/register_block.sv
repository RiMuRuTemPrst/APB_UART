`timescale 1ns / 1ps

module register_block (
    // Interface to APB (simplified by apb_interface)
    input  wire        pclk,
    input  wire        presetn,
    input  wire [12:0] reg_addr_i,
    input  wire [31:0] reg_wdata_i,
    input  wire [3:0]  reg_strb_i,
    input  wire        reg_we_i,
    output wire [31:0] reg_rdata_o,

    // Interface to UART Core (via apb_uart_system_top)
    input  wire        set_tx_done,
    input  wire        set_rx_done,
    input  wire        set_parity_error,
    input  wire [7:0]  rx_data_in,
    output wire [7:0]  tx_data_out,
    output wire        start_tx,
    output wire [4:0]  cfg_reg_out
);

    //===============================================================================
    // Internal Register Definitions
    //===============================================================================
    reg [31:0] tx_data_reg;
    reg [31:0] rx_data_reg;
    reg [31:0] cfg_reg;
    reg [31:0] ctrl_reg;
    reg [31:0] stt_reg; // Status register

    //===============================================================================
    // Address Map (using full 13-bit address from APB)
    //===============================================================================
    localparam TX_DATA_ADDR = 13'h000;
    localparam RX_DATA_ADDR = 13'h004;
    localparam CFG_ADDR     = 13'h008;
    localparam CTRL_ADDR    = 13'h00C;
    localparam STT_ADDR     = 13'h010;

    //===============================================================================
    // Main Synchronous Logic Block
    //===============================================================================
    always @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            tx_data_reg <= 32'b0;
            rx_data_reg <= 32'b0;
            cfg_reg     <= 32'b0;
            ctrl_reg    <= 32'b0;
            stt_reg     <= 32'b0;
        end else begin
            // --- Handle Register Writes from APB Interface ---
            if (reg_we_i) begin
                case (reg_addr_i)
                    TX_DATA_ADDR: begin
                        if(reg_strb_i[0]) tx_data_reg[7:0]   <= reg_wdata_i[7:0];
                        if(reg_strb_i[1]) tx_data_reg[15:8]  <= reg_wdata_i[15:8];
                        if(reg_strb_i[2]) tx_data_reg[23:16] <= reg_wdata_i[23:16];
                        if(reg_strb_i[3]) tx_data_reg[31:24] <= reg_wdata_i[31:24];
                    end
                    CFG_ADDR: begin
                        if(reg_strb_i[0]) cfg_reg[7:0] <= reg_wdata_i[7:0];
                    end
                    CTRL_ADDR: begin
                        if(reg_strb_i[0]) ctrl_reg[7:0] <= reg_wdata_i[7:0];
                    end
                    // Logic xóa cờ trạng thái: Ghi 1 vào bit tương ứng để xóa nó (Write-1-to-Clear)
                    STT_ADDR: begin
                        stt_reg <= stt_reg & ~reg_wdata_i;
                    end
                endcase
            end

            // --- Latch events into sticky status bits ---
            // Phần cứng chỉ set cờ, không tự xóa. Phần mềm (TB) phải xóa.
            if (set_tx_done)      stt_reg[0] <= 1'b1;
            if (set_rx_done)      stt_reg[1] <= 1'b1;
            if (set_parity_error) stt_reg[2] <= 1'b1;


            // --- Latch incoming data from UART RX ---
            if (set_rx_done) begin
                // Shift existing data right and load new byte into MSB part
                rx_data_reg <= {rx_data_in, rx_data_reg[31:8]};
            end
        end
    end

    //===============================================================================
    // Combinational Logic for Outputs
    //===============================================================================
    
    // Provide read data back to the APB interface
    assign reg_rdata_o = (reg_addr_i == TX_DATA_ADDR) ? tx_data_reg :
                         (reg_addr_i == RX_DATA_ADDR) ? rx_data_reg :
                         (reg_addr_i == CFG_ADDR)     ? cfg_reg :
                         (reg_addr_i == CTRL_ADDR)    ? ctrl_reg :
                         (reg_addr_i == STT_ADDR)     ? stt_reg :
                         32'hDEADBEEF; // Return error value for invalid read addr

    // Provide control/data signals to the UART Core
    assign tx_data_out = tx_data_reg[7:0]; // UART TX sends the lowest byte
    assign start_tx    = ctrl_reg[0];      // Assume bit 0 of CTRL_REG is 'start_tx'
    assign cfg_reg_out = cfg_reg[4:0];     // Provide 5 bits of config to UART core

endmodule