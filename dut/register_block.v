// Module: register_block
// Description: Register Block with control logic for APB-UART system (controller-based access)

module register_block (
    input              clk,
    input              rst_n,

    // APB Interface
    // input              wr_en,
    // input              rd_en,
    // input      [7:0]   addr,
    // input      [31:0]  wr_data,
    // output reg [31:0]  rd_data,

    // UART TX/RX Interface
    input              set_tx_done,
    input              set_rx_done,
    input              set_parity_error,
    input      [4:0]   reg_address,
    input      [31:0]  data_write_to_reg,
    input      [7:0]   rx_data_in,
    input              read_tx_data,
    input              read_rx_data,
    output reg         start_tx,
    output reg [7:0]   tx_data_out,
    output reg [7:0]   rx_data_out,
    output reg [4:0]   cfg_reg_out,
    output reg         read_tx_done,
    output reg         read_rx_done,
    output reg         read_parity_error
);

    // INTERNAL REGISTER
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
    //             rfu      [31:8]
    /////////////////////////////////////////////////////////////////////////////////////////////////////////        
    reg [31:0] ctrl_reg;
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Type: RW
    // Address: 0x00
    // Field Name: tx_done [0]
    //             rx_done [1]
    //             parity_error [2]
    /////////////////////////////////////////////////////////////////////////////////////////////////////////  
    reg [31:0] stt_reg;         // [0]=tx_done, [1]=rx_done, [2]=parity_error

    // Address map constants
    localparam TX_DATA_ADDR  = 5'h00;
    localparam RX_DATA_ADDR  = 5'h04;
    localparam CFG_ADDR      = 5'h08;
    localparam CTRL_ADDR     = 5'h0C;
    localparam STT_ADDR      = 5'h10;

    // Write logic based on reg_address
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
        begin
            tx_data_reg   <= 32'd0;
            rx_data_reg   <= 32'd0;
            cfg_reg       <= 32'd0;
            ctrl_reg      <= 32'd0;
            stt_reg       <= 32'd0;
        end else 
        begin
            case (reg_address)
                TX_DATA_ADDR: tx_data_reg       [7:0]  <= data_write_to_reg[7:0];
                RX_DATA_ADDR: rx_data_reg       [7:0]  <= rx_data_in;
                CFG_ADDR    : cfg_reg           [4:0]  <= data_write_to_reg[4:0];
                CTRL_ADDR   : ctrl_reg          [0]    <= data_write_to_reg[0];
                STT_ADDR    :
                begin
                        stt_reg[0] <= set_tx_done;
                        stt_reg[1] <= set_rx_done;
                        stt_reg[2] <= set_parity_error;
                end
                default:
                // begin
                    // Giữ nguyên giá trị cũ
                    // tx_data_reg   <= tx_data_reg;
                    // rx_data_reg   <= rx_data_reg;
                    // cfg_reg       <= cfg_reg;
                    // ctrl_reg      <= ctrl_reg;
                    // stt_reg       <= stt_reg; 
                // end
            endcase

            // Clear start_tx sau 1 chu kỳ
            if (reg_address != CTRL_ADDR)
                ctrl_reg[0] <= 1'b0;

            // Clear status flags sau khi đã báo hiệu ra ngoài 1 chu kỳ
            if (read_tx_done)      stt_reg[0] <= 1'b0;
            if (read_rx_done)      stt_reg[1] <= 1'b0;
            if (read_parity_error) stt_reg[2] <= 1'b0;
        end
    end

    // Outputs to UART logic
    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n) 
        begin
            tx_data_out        <= 8'd0;
            rx_data_out        <= 8'd0;
            start_tx           <= 1'b0;
            cfg_reg_out        <= 5'd0;
            read_tx_done       <= 1'b0;
            read_rx_done       <= 1'b0;
            read_parity_error  <= 1'b0;
        end else 
            begin
            if (read_tx_data)
            begin
                tx_data_out         <= tx_data_reg [7:0];
            end
            else tx_data_out        <= 8'd0;

            if (read_rx_data)
            begin
                rx_data_out         <= rx_data_reg [7:0];
            end
            else rx_data_out        <= 8'd0;

            start_tx            <= ctrl_reg[0];
            cfg_reg_out         <= cfg_reg [4:0];
            read_tx_done        <= stt_reg[0];
            read_rx_done        <= stt_reg[1];
            read_parity_error   <= stt_reg[2];
            end
    end
    
endmodule
