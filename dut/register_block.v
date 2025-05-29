module register_block (
    // APB interface signals
    input             pclk,              // APB clock
    input             presetn,           // APB reset, active LOW
    input             psel,              // APB select
    input             penable,           // APB enable
    input             pwrite,            // APB write

    input wire  [4:0]  reg_address_des,          // Register address to access
    input wire  [7:0]  data_write_to_reg,       // Data to write to register
    input wire         start_tx_signal,

    output reg [7:0]  rx_data_in,          // Received data from UART
    output reg        tx_done_signal,      // Signal to indicate TX done
    output reg        rx_done_signal,      // Signal to indicate RX done
    output reg        parity_error_signal  // Signal to indicate parity error
    // UART TX/RX Interface
    input             set_tx_done,
    input             set_rx_done,
    input             set_parity_error,
    input      [7:0]  rx_data_in,
    output reg [7:0]  tx_data_out,
    output reg        start_tx,
    output reg [4:0]  cfg_reg_out,
    output reg        read_tx_done,
    output reg        read_rx_done,
    output reg        read_parity_error
);

    //===============================================================================
    // INTERNAL REGISTERS
    //===============================================================================
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Type: RW                                                                                           //      
    // Address: 0x00                                                                                      //
    // Field Name: tx_data [7:0]                                                                          //                                      
    //             rfu     [31:8]                                                                         //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    reg [31:0] tx_data_reg;
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Type: RO
    // Address: 0x04
    // Field Name: rx_data [7:0]
    //             rfu     [31:8]
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    reg [31:0] rx_data_reg;
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Type: RW
    // Address: 0x08
    // Field Name: data_bit_num  [1:0]   00=5, 01=6, 10=7, 11=8
    //             stop_bit_num  [2]     0 = 1 stop bit, 1 = 2 stop bits
    //             parity_en     [3]     0 = no parity, 1 = parity enabled
    //             parity_type   [4]     0 = even parity, 1 = odd parity
    //             rfu           [31:5]
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    reg [31:0] cfg_reg;
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Type: RW
    // Address: 0x0C
    // Field Name: start_tx [0]
    //             rfu      [31:1]
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    reg [31:0] ctrl_reg;
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Type: RW
    // Address: 0x10
    // Field Name: tx_done [0]
    //             rx_done [1]
    //             parity_error [2]
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
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
    // APB write/read xử lý & ready/pslverr
    //===============================================================================
    always @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            // reset tất cả các thanh ghi
            tx_data_reg    <= 32'd0;
            rx_data_reg    <= 32'd0;
            cfg_reg        <= 32'd0;
            ctrl_reg       <= 32'd0;
            stt_reg        <= 32'd0;
            // APB signals
            pready         <= 1'b0;
            pslverr        <= 1'b0;
            prdata         <= 32'd0;
        end else begin
            // mặc định
            pready      <= 1'b0;
            pslverr     <= 1'b0;

            if (psel && penable) begin
                if (pwrite) begin
                    // ----- WRITE -----
                    case (paddr)
                        TX_DATA_ADDR: begin
                            if (pstrb[0])
                                tx_data_reg[7:0] <= pwdata[7:0];
                        end
                        CFG_ADDR: begin
                            // chỉ cập nhật 5 bit thấp
                            cfg_reg[4:0] <= pwdata[4:0];
                        end
                        CTRL_ADDR: begin
                            ctrl_reg[0] <= pwdata[0];
                        end
                        default: begin
                            // không có vùng nào hợp lệ
                            pslverr <= 1'b1;
                        end
                    endcase
                    pready <= 1'b1;
                end else begin
                    // ----- READ -----
                    case (paddr)
                        TX_DATA_ADDR: prdata <= {24'b0, tx_data_reg[7:0]};
                        RX_DATA_ADDR: prdata <= {24'b0, rx_data_reg[7:0]};
                        CFG_ADDR:     prdata <= {27'b0, cfg_reg[4:0]};
                        CTRL_ADDR:    prdata <= {31'b0, ctrl_reg[0]};
                        STT_ADDR:     prdata <= stt_reg;
                        default: begin
                            prdata   <= 32'd0;
                            pslverr  <= 1'b1;
                        end
                    endcase
                    pready <= 1'b1;
                end
            end

            // cập nhật status từ UART core
            stt_reg[0] <= set_tx_done   ? 1'b1 : stt_reg[0];
            stt_reg[1] <= set_rx_done   ? 1'b1 : stt_reg[1];
            stt_reg[2] <= set_parity_error ? 1'b1 : stt_reg[2];

            // clear status khi CPU đã đọc
            if (psel && penable && !pwrite && paddr == STT_ADDR) begin
                if (read_tx_done)      stt_reg[0] <= 1'b0;
                if (read_rx_done)      stt_reg[1] <= 1'b0;
                if (read_parity_error) stt_reg[2] <= 1'b0;
            end

            // register rx_data luôn lấy đầu vào mới mỗi xung
            rx_data_reg[7:0] <= rx_data_in;
        end
    end

    //===============================================================================
    // Đưa giá trị ra ngoài (UART logic)
    //===============================================================================
    always @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            tx_data_out       <= 8'd0;
            start_tx          <= 1'b0;
            cfg_reg_out       <= 5'd0;
            read_tx_done      <= 1'b0;
            read_rx_done      <= 1'b0;
            read_parity_error <= 1'b0;
            rx_data_out       <= 8'd0;
        end else begin
            // Lấy dữ liệu được yêu cầu đọc
            tx_data_out       <= tx_data_reg[7:0];
            start_tx          <= ctrl_reg[0];
            cfg_reg_out       <= cfg_reg[4:0];
            read_tx_done      <= stt_reg[0];
            read_rx_done      <= stt_reg[1];
            read_parity_error <= stt_reg[2];
            rx_data_out       <= rx_data_reg[7:0];
        end
    end

endmodule
