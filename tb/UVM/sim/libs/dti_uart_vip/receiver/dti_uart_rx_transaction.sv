/*******************************************************************************
 *    Copyright (C) 2024 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_uart_rx_transaction.sv
 *    Company     : Dolphin Technology
 *    Project     : dti uart vip
 *    Author      : Lam Pham Ngoc
 *    Module/Class: dti_uart_rx_transaction
 *    Create Date : Jul 03 2024
 *    Last Update : Jul 03 2024
 *    Description : UART RX transaction
 ******************************************************************************
  History:

 ******************************************************************************/

class dti_uart_rx_transaction extends uvm_sequence_item;
  // UART TX configuration
  dti_uart_configuration uart_rx_cfg;

  uart_data_frame_t uart_rx_data_frame;

  bit parity_error;
  bit stop_error;

  `uvm_object_utils_begin(dti_uart_rx_transaction)
    `uvm_field_int      (uart_rx_data_frame, UVM_ALL_ON)
  `uvm_object_utils_end

  extern function      new(string name="dti_uart_rx_transaction");

endclass : dti_uart_rx_transaction


// Function: new
// Constructor of object.
function dti_uart_rx_transaction::new(string name="dti_uart_rx_transaction");
  super.new(name);
endfunction
