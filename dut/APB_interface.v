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
    input  wire [3:0]  pstrb,      // APB strobe signal for byte selection

    output reg         pready,      // APB ready signal
    output reg  [31:0] prdata,      // APB read data bus
    output reg         pslverr,     // APB slave error signal
    //===============================================================================
    // Apb_interface -> register_block
    output reg  [4:0]  reg_address_des,          // Register address to access
    output reg  [7:0]  data_write_to_reg,       // Data to write to register

    //===============================================================================
    // Apb_interface <- register_block
    input  wire [7:0]  rx_data_in,          // Received data from UART
    input  wire        tx_done_signal,      // Signal to indicate TX done
    input  wire        rx_done_signal,      // Signal to indicate RX done
    input  wire        parity_error_signal  // Signal to indicate parity error
)
    //===============================================================================
    // Internal signals
    reg [31:0] sent_buffer;     // Data to be written to register
    reg [31:0] receive_buffer;   // Data read from register
    //===============================================================================
    localparam  SET_UP = 1'b0,
                TRANSFER = 1'b1;
    reg current_state;
    reg transfer_done;
    reg next_state;
    reg invalid_address;
    reg [3:0] chosen_byte_sent; // Chosen byte to be sent
    reg [2:0] byte_sent_counter;
    reg sent_tx_done_signal;
    //===============================================================================
    //  Next State Logic
    always @(presetn or psel or penable or pwrite or paddr or pwdata or transfer_done)
    begin
        if (!presetn) 
        begin
            next_state = SET_UP; // Reset to setup phase
            invalid_address = 1'b0; // Reset invalid address flag
            sent_buffer = 32'b0; // Reset data to be written to register
        end else 
        begin
            if (psel && penable) //SET_UP -> TRANSFER
            // penable = 1 is the signal of transfer phase 
            begin
                // If we are in SET_UP state and we want to write to a valid address
                if (current_state == SET_UP && pwrite)
                begin
                    // 0x0, 0x8, 0xC is RW register
                    if ((paddr[12:0] == 13'b0000000000000) || (paddr[12:0] == 13'b0000000001000) || 
                    (paddr[12:0] == 13'b0000000001100))
                    begin
                        // If we are in setup phase and address is valid, move to transfer phase
                        next_state = TRANSFER;
                        invalid_address = 1'b0; // Address is valid
                        sent_buffer = pwdata;  // Store data to be written to register
                    end else
                    begin 
                        next_state = SET_UP; // Remain in setup phase if address is invalid
                        invalid_address = 1'b1; // Address is invalid
                    end
                end
                // IF we are in SET_UP state and we want to read from a valid address
                else if (current_state == SET_UP && !pwrite)
                begin
                    if ((paddr[12:0] == 13'b0000000000000) || (paddr[12:0] == 13'b0000000001000) 
                    || (paddr[12:0] == 13'b0000000001100) || (paddr[12:0] == 13'b0000000010000) 
                    || (paddr[12:0] == 13'b0000000000100))
                    begin
                        // If we are in setup phase and address is valid, move to transfer phase
                        next_state = TRANSFER;
                        invalid_address = 1'b0; // Address is valid
                    end else
                    begin
                        next_state = SET_UP; // Remain in setup phase if address is invalid
                        invalid_address = 1'b1; // Invalid address
                    end
                end
            end else if (transfer_done) // If transfer is done, move to SET_UP phase (TRANSFER -> SET_UP)
            begin
                // If transfer is done, move back to SET_UP phase
                next_state = SET_UP;
                invalid_address = 1'b0; // Reset invalid address flag
                sent_buffer = 32'b0; // Reset data to be written to register
            end else
            begin
                // psel always = 1, penable = 0 -> hold state (SET_UP -> SET_UP , TRANSFER -> TRANSFER)
                next_state = current_state;
            end
        end
    end
    //===============================================================================
    // Present State Logic
    always @(posedge pclk)
    begin
        current_state <= next_state; // Update to next state
    end
    //===============================================================================
    // Output Logic
    always @(tx_done_signal or pwrite or pwdata or paddr or current_state or presetn)
    begin
        if (!presetn) 
        begin
            pready <= 1'b0;
            prdata <= 32'b0;
            pslverr <= 1'b0;
            reg_address_des <= 5'b0;
            data_write_to_reg <= 8'b0;
            current_state <= SET_UP;
            byte_sent_counter <= 0;
            chosen_byte_sent <= 4'b0;
        end else 
        begin
            case (current_state)
                SET_UP: 
                begin
                    if (invalid_address) // Hold in Set up phase because of invalid address
                    begin
                        pready          = 1'b0; 
                        pslverr         = 1'b1; // Set slave error signal
                        transfer_done   = 1'b0;
                    end else             // penable = 0 ->Still in SET_UP phase
                    begin
                        pready          = 1'b0; // Not ready if address is invalid
                        pslverr         = 1'b0; // Set slave error signal
                        transfer_done   = 1'b0; // Reset transfer done signal
                    end 
                end
                // If machine can move to Transfer phase, means address is valid
                TRANSFER: // In transfer phase, there are 2 cases: write and read
                chosen_byte_sent = pstrb;
                begin
                    if (pwrite) // If write operation
                    begin
                        if (tx_done_signal) // If TX done signal is received
                        begin
                            if (paddr[12:0] ==  13'b0000000001000) //Write to cfg_reg
                            begin
                                reg_address_des     = paddr         [4:0];    // Set register address
                                data_write_to_reg   = sent_buffer   [7:0];    // Set data to write to register
                                transfer_done       = 1'b1;                   // Set transfer done signal         
                            end
                            else if (paddr[12:0] ==  13'b0000000001100) //Write to ctrl_reg (sey start_tx signal)
                            begin
                                reg_address_des     = paddr         [4:0];    // Set register address
                                data_write_to_reg   = sent_buffer   [7:0];    // Set data to write to register
                                transfer_done       = 1'b1;                   // Set transfer done signal
                            end
                            else if (paddr[12:0] ==  13'b0000000000000) //Write to tx_data_reg
                            // Write data base on pstrb signal
                            begin
                                if (byte_sent_counter == 0)
                                begin
                                    if (chosen_byte_sent[0]) // If byte 0 is selected
                                    begin
                                        reg_address_des     = paddr         [4:0];    // Set register address
                                        data_write_to_reg   = sent_buffer   [7:0];    // Set data to write to register
                                        byte_sent_counter   = 1; // Increment byte sent counter
                                    end
                                    else byte_sent_counter = 1;
                                end
                                else if (byte_sent_counter == 1)
                                begin
                                    if (chosen_byte_sent[1]) // If byte 1 is selected
                                    begin
                                        reg_address_des     = paddr         [4:0];    // Set register address
                                        data_write_to_reg   = sent_buffer   [15:8];  // Set data to write to register
                                        byte_sent_counter   = 2; // Increment byte sent counter
                                    end
                                    else byte_sent_counter = 2;
                                end
                                else if (byte_sent_counter == 2)
                                begin
                                    if (chosen_byte_sent[2]) // If byte 2 is selected
                                    begin
                                        reg_address_des     = paddr         [4:0];    // Set register address
                                        data_write_to_reg   = sent_buffer   [23:16]; // Set data to write to register
                                        byte_sent_counter   = 3; // Increment byte sent counter
                                    end
                                    else byte_sent_counter = 3;
                                end
                                else if (byte_sent_counter == 3)
                                begin
                                    if (chosen_byte_sent[3]) // If byte 3 is selected
                                    begin
                                        reg_address_des     = paddr         [4:0];    // Set register address
                                        data_write_to_reg   = sent_buffer   [31:24]; // Set data to write to register
                                        byte_sent_counter   = 0; // Reset byte sent counter for next write operation
                                    end
                                    else byte_sent_counter = 0; // Reset counter for next write operation
                                end else 
                                begin
                                    reg_address_des     = 5'b0; // Reset register address
                                    data_write_to_reg   = 8'b0; // Reset data to write to register
                                end
                                transfer_done = 1'b1;  
                            end
                        end else // If tx_done_signal = 0 -> UART is still transmitting
                        begin
                            transfer_done = 1'b0; // Not done yet
                        end
                    end else //    If read operation
                    begin

                    end
                end
                default: // Default case to handle unexpected states -> Reset 
                begin
                    pready              = 1'b0; // Not ready in default state
                    pslverr             = 1'b0; // Set slave error signal
                    reg_address_des     = 5'b0; // Reset register address
                    data_write_to_reg   = 8'b0; // Reset data to write to register
                end
            endcase
        end
    end

    
endmodule