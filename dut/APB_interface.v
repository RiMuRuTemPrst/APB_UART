module apb_interface
( parameter TIMEOUT_CYCLES = 50_000_000 * 1) //  Clock cycles for 1 second timeout at 50 MHz clock
    //===============================================================================
    // APB interface signals
    //===============================================================================
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
    output reg         start_tx_signal,
    //===============================================================================
    // Apb_interface <- register_block
    input  wire [7:0]  rx_data_in,          // Received data from UART
    input  wire        tx_done_signal,      // Signal to indicate TX done
    input  wire        rx_done_signal,      // Signal to indicate RX done
    input  wire        parity_error_signal  // Signal to indicate parity error
)
    //===============================================================================
    // Internal buffer
    reg [31:0] sent_buffer;     // Data to be written to register
    reg [31:0] receive_buffer;   // Data read from register
    //===============================================================================
    // Internal signals
    localparam  SET_UP = 1'b0,
                TRANSFER = 1'b1;
    reg current_state;
    reg next_state;
    reg transfer_done;                  // Signal to indicate transfer is done to change state
    reg invalid_address;                // Flag to indicate if address is valid or not (1 = invalid, 0 = valid)
    reg [3:0] chosen_byte_sent;         // Chosen byte to be sent
    reg [2:0] byte_sent_counter;
    reg [2:0] byte_received_counter; // Counter for received bytes
    reg errror_flag;
    //===============================================================================
    // Time out Counter variables
    reg [$clog2(TIMEOUT_CYCLES):0] counter;
    reg reset_counter;

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
            else if (psel && !penable) // If psel = 1 and penable = 0 -> SET_UP state
            begin
                next_state = SET_UP; // Remain in SET_UP phase
                invalid_address = 1'b0; // Reset invalid address flag
                sent_buffer = 32'b0; // Reset data to be written to register
            end
            else begin
                // psel always = 1, penable = 0 -> hold state (SET_UP -> SET_UP , TRANSFER -> TRANSFER)
                next_state = current_state;
            end
        end
    end
    //===============================================================================
    // Present State Logic
    always @(posedge pclk or presetn)
    begin
        if (!presetn)
        begin
            current_state       <= SET_UP; // Reset to setup phase
        end else current_state  <= next_state; // Update to next state
    end
    //===============================================================================
    // Output Logic
    always @(posedge pclk)
    begin
        if (!presetn) 
        begin
            pready <= 1'b0;
            prdata <= 32'b0;
            pslverr <= 1'b0;
            reg_address_des <= 5'b0;
            data_write_to_reg <= 8'b0;
            byte_sent_counter <= 0;
            chosen_byte_sent <= 4'b0;
            receive_buffer <= 32'b0; // Reset receive buffer
            counter <= 0;
            reset_counter <= 1'b1; // Reset counter on reset
            transfer_done <= 1'b0; // Reset transfer done signal
            start_tx_signal <= 1'b0; // Reset start_tx signal
            errror_flag <= 1'b0; // Reset error flag
            byte_received_counter <= 0; // Reset byte received counter
            byte_received_counter <= 0; // Reset byte received counter
        end else 
        begin
            case (current_state)
                SET_UP: 
                begin
                    if (invalid_address) // Hold in Set up phase because of invalid address
                    begin
                        transfer_done       <= 1'b0;
                        pready              <= 1'b0; 
                        pslverr             <= 1'b1;  // Set slave error signal
                        prdata              <= 32'b0; // Reset read data bus
                        reg_address_des     <= 5'b0;  // Reset register address
                        data_write_to_reg   <= 8'b0; // Reset data to write to register
                    end else             // penable = 0 ->Still in SET_UP phase
                    begin
                        transfer_done       <= 1'b0; // Reset transfer done signal
                        pready              <= 1'b0; // Not ready if address is invalid
                        pslverr             <= 1'b0; // Set slave error signal
                        prdata              <= 32'b0; // Reset read data bus
                        reg_address_des     <= 5'b0;  // Reset register address
                        data_write_to_reg   <= 8'b0; // Reset data to write to register
                    end 
                end
                // If machine can move to Transfer phase, means address is valid
                TRANSFER: // In transfer phase, there are 2 cases: write and read
                begin
                    chosen_byte_sent <= pstrb;
                    if (pwrite) // If WRITE operation
                    begin
                        prdata <= 32'b0; // Reset read data bus
                        if (start_tx_signal) start_tx_signal <= 1'b0; // Reset start_tx signal after 1 clk
                        if (tx_done_signal) // If TX done signal is received
                        begin
                            if (paddr[12:0] ==  13'b0000000001000) //Write to cfg_reg
                            begin
                                reg_address_des     <= paddr         [4:0];    // Set register address
                                data_write_to_reg   <= sent_buffer   [7:0];    // Set data to write to register
                                transfer_done       <= 1'b1;                   // Set transfer done signal    
                                pslverr             <= 1'b0;                   // No error in transfer 
                                pready              <= 1'b1;                   // Set ready signal
                                prdata              <= 32'b0;                   // Reset read data bus
                                start_tx_signal     <= 1'b0;                   // DON'T Start Tx
                            end
                            else if (paddr[12:0] ==  13'b0000000001100) //Write to ctrl_reg (sey start_tx signal)
                            begin
                                reg_address_des     <= paddr         [4:0];    // Set register address
                                data_write_to_reg   <= sent_buffer   [7:0];    // Set data to write to register
                                transfer_done       <= 1'b1;                   // Set transfer done signal
                                pslverr             <= 1'b0;                   // No error in transfer 
                                pready              <= 1'b1;                   // Set ready signal
                                prdata              <= 32'b0;                  // Reset read data bus
                                start_tx_signal     <= sent_buffer[0];         // Set start_tx signal based on ctrl_reg data
                            end
                            else if (paddr[12:0] ==  13'b0000000000000) //Write to tx_data_reg
                            // Write data base on pstrb signal
                            begin
                                if (byte_sent_counter == 0)
                                begin
                                    if (chosen_byte_sent[0]) // If byte 0 is selected
                                    begin
                                        reg_address_des     <= paddr         [4:0];    // Set register address
                                        data_write_to_reg   <= sent_buffer   [7:0];    // Set data to write to register
                                        byte_sent_counter   <= 1; // Increment byte sent counter
                                        start_tx_signal     <= 1'b1; // Set start_tx signal to indicate transmission start
                                    end
                                    else byte_sent_counter <= 1;
                                end
                                else if (byte_sent_counter == 1)
                                begin
                                    if (chosen_byte_sent[1]) // If byte 1 is selected
                                    begin
                                        reg_address_des     <= paddr         [4:0];    // Set register address
                                        data_write_to_reg   <= sent_buffer   [15:8];  // Set data to write to register
                                        byte_sent_counter   <= 2; // Increment byte sent counter
                                        start_tx_signal     <= 1'b1; // Set start_tx signal to indicate transmission start
                                    end
                                    else byte_sent_counter <= 2;
                                end
                                else if (byte_sent_counter == 2)
                                begin
                                    if (chosen_byte_sent[2]) // If byte 2 is selected
                                    begin
                                        reg_address_des     <= paddr         [4:0];    // Set register address
                                        data_write_to_reg   <= sent_buffer   [23:16]; // Set data to write to register
                                        byte_sent_counter   <= 3; // Increment byte sent counter
                                        start_tx_signal     <= 1'b1; // Set start_tx signal to indicate transmission start
                                    end
                                    else byte_sent_counter <= 3;
                                end
                                else if (byte_sent_counter == 3)
                                begin
                                    if (chosen_byte_sent[3]) // If byte 3 is selected
                                    begin
                                        reg_address_des     <= paddr         [4:0];    // Set register address
                                        data_write_to_reg   <= sent_buffer   [31:24]; // Set data to write to register
                                        byte_sent_counter   <= 0; // Reset byte sent counter for next write operation\
                                        start_tx_signal     <= 1'b1; // Set start_tx signal to indicate transmission start
                                    end
                                    else byte_sent_counter <= 4; // Reset counter for next write operation
                                end else 
                                begin
                                    reg_address_des     <= 5'b0; // Reset register address
                                    start_tx_signal     <= 1'b0; // Reset start_tx signal if no byte is selected
                                    data_write_to_reg   <= 8'b0; // Reset data to write to register
                                end
                            end
                        end else // If tx_done_signal = 0 -> UART is still transmitting
                        begin
                            transfer_done <= 1'b0; // Not done yet
                        end
                        if (byte_sent_counter == 4) // If all 4 bytes are sent
                        begin
                            transfer_done <= 1'b1;  
                            pslverr <= 1'b0; // No error in transfer
                            pready <= 1'b1; // Set ready signal
                            byte_sent_counter <= 0; // Reset byte sent counter for next write operation
                        end
                        else byte_sent_counter <= byte_sent_counter; // Hold byte sent counter if not all bytes are sent
                    end else //    If READ operation (pwrite = 0)
                    begin
                        data_write_to_reg <= 8'b0; // Reset data to write to register
                        start_tx_signal   <= 1'b0; // Reset start_tx signal
                        if (paddr[12:0] ==  13'b0000000000000) //Read from rx_data_reg
                        begin
                            reg_address_des     <= paddr[4:0];    // Set register address
                            prdata              <= {24'b0, rx_data_in}; // Read data from UART
                            transfer_done       <= 1'b1; // Set transfer done signal
                            pslverr             <= 1'b0; // No error in transfer 
                            pready              <= 1'b1; // Set ready signal

                        end
                        else if (paddr[12:0] ==  13'b0000000001000) //Read from cfg_reg
                        begin
                            reg_address_des     <= paddr[4:0];    // Set register address
                            prdata              <= {24'b0, rx_data_in}; // Read data from UART (cfg_reg is not used in this design)
                            transfer_done       <= 1'b1; // Set transfer done signal
                            pslverr             <= 1'b0; // No error in transfer 
                            pready              <= 1'b1; // Set ready signal
                        end
                        else if (paddr[12:0] ==  13'b0000000001100) //Read from ctrl_reg
                        begin
                            reg_address_des     <= paddr[4:0];    // Set register address
                            prdata              <= {24'b0, rx_data_in}; // Read data from UART (ctrl_reg is not used in this design)
                            transfer_done       <= 1'b1; // Set transfer done signal
                            pslverr             <= 1'b0; // No error in transfer 
                            pready              <= 1'b1; // Set ready signal
                        end
                        else if (paddr[12:0] ==  13'b0000000010000) //Read from stt_reg
                        begin
                            reg_address_des     <= paddr[4:0];    // Set register address
                            prdata              <= {24'b0, rx_data_in}; // Read data from UART (stt_reg is not used in this design)
                            transfer_done       <= 1'b1; // Set transfer done signal
                            pslverr             <= 1'b0; // No error in transfer 
                            pready              <= 1'b1; // Set ready signal
                        end
                        else if (paddr[12:0] ==  13'b0000000000100) //Read from data_reg
                        // Read data from UART 
                        begin
                            if (rx_done_signal) // If RX done signal is received
                            begin
                                if (byte_received_counter == 0)
                                begin
                                    receive_buffer          <= {24'b0, rx_data_in};             // Store received data in buffer
                                    reg_address_des         <= paddr[4:0];                      // Set register address
                                    prdata                  <= receive_buffer;                  // Set read data bus to received data
                                    transfer_done           <= 1'b0;                            // Not done yet
                                    errror_flag                 <= errror_flag | parity_error_signal;   // No error in transfer
                                    pready                  <= 1'b0;                            // Set ready signal
                                       // Reset start_tx signal
                                    reset_counter           <= 1'b1;                            // Reset counter
                                    byte_received_counter   <= byte_received_counter + 1;       // Increment byte received counter
                                end
                                else if (byte_received_counter == 1)
                                begin
                                    receive_buffer          <= {receive_buffer[31:16], rx_data_in, receive_buffer [7:0] }; // Store received data in buffer
                                    prdata                  <= receive_buffer;                  // Set read data bus to received data
                                    transfer_done           <= 1'b0;                            // Not done yet
                                    errror_flag             <= errror_flag | parity_error_signal;   // No error in transfer
                                    pready                  <= 1'b0;                            // Set ready signal
                                    data_write_to_reg       <= 8'b0;                            // Reset data to write to register
                                       // Reset start_tx signal
                                    reset_counter           <= 1'b1;                            // Reset counter
                                    byte_received_counter   <= byte_received_counter + 1;       // Increment byte received counter
                                end
                                else if (byte_received_counter == 2)
                                begin
                                    receive_buffer          <= {receive_buffer[31:24],rx_data_in, receive_buffer [15:0]}; // Store received data in buffer
                                    reg_address_des         <= paddr[4:0];                      // Set register address
                                    prdata                  <= receive_buffer;                  // Set read data bus to received data
                                    transfer_done           <= 1'b0;                            // Not done yet
                                    errror_flag             <= errror_flag | parity_error_signal;   // No error in transfer
                                    pready                  <= 1'b0;                            // Set ready signal
                                       // Reset start_tx signal
                                    reset_counter           <= 1'b1;                            // Reset counter
                                    byte_received_counter   <= byte_received_counter + 1;       // Increment byte received counter
                                end
                                else if (byte_received_counter == 3)
                                begin
                                    receive_buffer          <= {rx_data_in, receive_buffer [23:0]}; // Store received data in buffer
                                    reg_address_des         <= paddr[4:0];                      // Set register address
                                    prdata                  <= receive_buffer;                  // Set read data bus to received data
                                    transfer_done           <= 1'b1;                            // Set transfer done signal
                                    errror_flag             <= errror_flag | parity_error_signal;   // No error in transfer
                                    pready                  <= 1'b0;                            // Set ready signal
                                       // Reset start_tx signal
                                    reset_counter           <= 1'b1;                            // Reset counter
                                    byte_received_counter   <= byte_received_counter + 1;                               // Reset byte received counter for next read operation
                                end else
                                begin
                                    reg_address_des         <= 5'b0; // Reset register address
                                    prdata                  <= 32'b0; // Reset read data bus
                                    transfer_done           <= 1'b0; // Not done yet
                                    errror_flag                 <= errror_flag | parity_error_signal; // No error in transfer
                                    pready                  <= 1'b0; // Set ready signal
                                    
                                    reset_counter           <= 1'b1; // Reset counter
                                end
                            end 
                            else // If rx_done_signal = 0 -> UART is still receiving -> Waiting
                                begin
                                    if (reset_counter)
                                        begin
                                            reset_counter <= 1'b0; // Reset counter
                                            counter <= 0; // Reset counter
                                        end
                                    else 
                                    begin
                                        if (counter == TIMEOUT_CYCLES)
                                            begin
                                                pslverr <= 1'b1; // Set slave error signal
                                                pready <= 1'b1;  
                                                transfer_done <= 1'b1; // Not done yet
                                                reg_address_des <= paddr[4:0]; // Set register address
                                                prdata <= receive_buffer; // Read data from receive buffer
                                                                                         byte_received_counter <= 0; // Reset byte received counter
                                                errror_flag <= 1'b0; // Reset error flag
                                                reset_counter <= 1'b1; // Reset counter
                                            end
                                        else
                                            begin
                                                counter <= counter + 1; // Increment counter
                                            end
                                    end
                                end
                            // IF PCB received 4 byte -> Done Transfer
                            if (byte_received_counter == 4) // If RX done signal is not received
                            begin
                                reg_address_des         <= paddr[4:0]; // Set register address
                                prdata                  <= receive_buffer; // Set read data bus to received data
                                transfer_done           <= 1'b1; // Done Reading 
                                pslverr                 <= pslverr; // No error in transfer
                                pready                  <= 1'b1; // Set ready signal
                                reset_counter           <= 1'b0; // Reset counter
                                byte_received_counter   <= 0; // Reset byte received counter for next read operation
                            end
                        end
                    end
                end
                default: // Default case to handle unexpected states -> Reset 
                begin
                    pready              <= 1'b0;     // Not ready in default state
                    pslverr             <= 1'b0;     // Set slave error signal
                    data_write_to_reg   <= 8'b0;     // Reset data to write to register
                    prdata              <= 32'b0;    // Reset read data bus
                    reg_address_des     <= 5'b0;     // Reset register address
                    reset_counter       <= 1'b1;     // Reset counter
                    transfer_done       <= 1'b0;     // Reset transfer done signal
                    byte_sent_counter   <= 0;       // Reset byte sent counter
                    chosen_byte_sent    <= 4'b0;     // Reset chosen byte sent
                end
            endcase
        end
    end
endmodule