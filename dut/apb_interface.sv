`timescale 1ns / 1ps

module apb_interface (
    // APB Bus signals
    input  wire        pclk,
    input  wire        presetn,
    input  wire        psel,
    input  wire        penable,
    input  wire        pwrite,
    input  wire [12:0] paddr,
    input  wire [31:0] pwdata,
    input  wire [3:0]  pstrb,

    output reg         pready,
    output reg  [31:0] prdata,
    output reg         pslverr,

    // Interface to the Register Block (sửa thành wire và assign)
    output wire [12:0] reg_addr_o,
    output wire [31:0] reg_wdata_o,
    output wire [3:0]  reg_strb_o,
    output wire        reg_we_o,
    input  wire [31:0] reg_rdata_i
);

    wire valid_addr;

    // Address Decoder - determines if the access is to a valid address
    assign valid_addr = (paddr == 13'h000) || (paddr == 13'h004) || 
                      (paddr == 13'h008) || (paddr == 13'h00C) || 
                      (paddr == 13'h010);

    //=======================================================================
    // Logic tổ hợp để điều khiển register block (KHÔNG CÓ ĐỘ TRỄ)
    //=======================================================================
    assign reg_addr_o  = paddr;
    assign reg_wdata_o = pwdata;
    assign reg_strb_o  = pstrb;
    // Write enable chỉ được bật trong pha ACCESS của một giao dịch ghi hợp lệ
    assign reg_we_o    = psel && penable && pwrite && valid_addr;

    //=======================================================================
    // Logic đồng bộ để điều khiển bus APB
    //=======================================================================
    always @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            pready  <= 1'b0;
            pslverr <= 1'b0;
            prdata  <= 32'b0;
        end else begin
            // pready chỉ lên 1 trong pha ACCESS (psel && penable)
            if (psel && penable) begin
                pready  <= 1'b1;
                pslverr <= ~valid_addr; // Báo lỗi nếu địa chỉ không hợp lệ
                
                // Trong pha ACCESS của một lệnh đọc, xuất dữ liệu ra prdata
                if (!pwrite) begin
                    prdata <= reg_rdata_i; 
                end else begin
                    prdata <= 32'b0;
                end
            end else begin
                // Ngoài pha ACCESS, các tín hiệu ở trạng thái chờ
                pready  <= 1'b0;
                pslverr <= 1'b0;
                prdata  <= 32'b0;
            end
        end
    end

endmodule