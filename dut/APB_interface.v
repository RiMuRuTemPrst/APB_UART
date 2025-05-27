module apb_interface
(
    //===============================================================================
    // Input of APB protocol
    input  wire        pclk,        // APB clock
    input  wire        presetn,     // APB reset, active LOW
    input  wire        psel,        // APB select signal
    input  wire        penable,     // APB enable signal
    input  wire        pwrite,      // APB write signal
    input  wire [12:0] paddr,       // APB address bus
    input  wire [31:0] pwdata,      // APB write data bus

    output reg         pready,      // APB ready signal
    output reg  [31:0] prdata,      // APB read data bus
    output reg         pslverr,     // APB slave error signal
    //===============================================================================
    // Apb_interface -> register_block
    output reg  [4:0]  reg_address          // Register address to access
    output reg  [7:0]  data_write_to_reg    // Data to write to register
    output reg         start_tx             // Start transmission signal

    //===============================================================================
    // Apb_interface <- register_block
    input  wire [7:0]  rx_data_in,          // Received data from UART
    input  wire        tx_done_signal,      // Signal to indicate TX done
    input  wire        rx_done_signal,      // Signal to indicate RX done
    input  wire        parity_error_signal  // Signal to indicate parity error
)
    //===============================================================================
    // Internal signals
    reg [31:0] data_to_reg; // Data to be written to register
    reg [31:0] data_from_reg; // Data read from register
    //===============================================================================
    localparam  SET_UP = 1'b0,
                TRASNFER = 1'b1;
    reg current_state;
    reg transfer_done;
    reg next_state;
    reg invalid_address;
    //===============================================================================
    //  Next State Logic
    always @(presetn or psel or penable or pwrite or paddr or pwdata or transfer_done)
    begin
        if (!presetn) 
        begin
            next_state = SET_UP; // Reset to setup phase
        end else 
        begin
            // If 
            if (psel && penable) 
            begin
                // If we are in SET_UP state and we want to write to a valid address
                if (current_state == SET_UP && pwrite)
                begin
                    // 0x0, 0x8, 0xC is RW register
                    if (paddr[12:0] == 13'b0000000000000 or paddr[12:0] == 13'b0000000001000 or paddr[12:0] == 13'b0000000001100)
                    begin
                        // If we are in setup phase and address is valid, move to transfer phase
                        next_state = TRASNFER;
                        invalid_address = 1'b0; // Address is valid
                    end else
                    begin 
                        next_state = SET_UP; // Remain in setup phase if address is invalid
                        invalid_address = 1'b1; // Address is invalid
                    end
                end
                // IF we are in SET_UP state and we want to read from a valid address
                else if (current_state == SET_UP && !pwrite)
                begin
                    if (paddr[12:0] == 13'b0000000000000 or paddr[12:0] == 13'b0000000001000 or paddr[12:0] == 13'b0000000001100 or 
                    paddr[12:0] == 13'b0000000010000 or paddr[12:0] == 13'b0000000000100)
                    begin
                        // If we are in setup phase and address is valid, move to transfer phase
                        next_state = TRASNFER;
                        invalid_address = 1'b0; // Address is valid
                    end else
                    begin
                        next_state = SET_UP; // Remain in setup phase if address is invalid
                        invalid_address = 1'b1; // Invalid address
                    end
                end
            end else 
            begin
                // Remain in the current phase until transfer is done
                next_state = SET_UP;
            end
            // If we are in setup phase, we just change phase when the address is valid
            
            end
        end
    always @(posedge pclk or negedge presetn) 
    begin
        if (!presetn) 
        begin
            pready <= 1'b0;
            prdata <= 32'b0;
            pslverr <= 1'b0;
            reg_address <= 5'b0;
            data_write_to_reg <= 8'b0;
            start_tx <= 1'b0;
            current_phase <= SET_UP;
        end else 
        begin
            case (current_phase)
                SET_UP: 
                begin
                    if (psel) begin
                        pready <= 1'b0; // Not ready until we process the request
                        reg_address <= paddr[4:0]; // Extract register address from paddr
                        if (pwrite) begin
                            data_write_to_reg <= pwdata[7:0]; // Write data to register
                            current_phase <= ACCESS; // Move to access phase
                        end else begin
                            current_phase <= ACCESS; // Move to access phase for read operation
                        end
                    end else begin
                        pready <= 1'b1; // Not selected, ready to accept next request
                    end
                end

                ACCESS: begin
                    if (pwrite) begin
                        // Write operation, set the data to be written to register
                        data_to_reg <= {24'b0, data_write_to_reg};
                        pready <= 1'b1; // Indicate ready after write operation
                    end else begin
                        // Read operation, set the data from register to prdata
                        prdata <= {24'b0, rx_data_in}; // Assuming rx_data_in is the data read from UART
                        pready <= 1'b1; // Indicate ready after read operation
                    end

                    // Check for done signals and errors
                    if (tx_done_signal || rx_done_signal || parity_error_signal) begin
                        pslverr <= parity_error_signal; // Set error signal if parity error occurs
                    end else begin
                        pslverr <= 1'b0; // No error signal otherwise
                    end

                    current_phase <= SET_UP; // Go back to setup phase for next transaction
                end

                default: current_phase <= SET_UP; // Default case to handle unexpected states

            endcase
        end
    end

    
endmodule