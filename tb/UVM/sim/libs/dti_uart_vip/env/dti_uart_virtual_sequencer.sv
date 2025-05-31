/*******************************************************************************
 *    Copyright (C) 2024 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_uart_virtual_sequencer.sv
 *    Company     : Dolphin Technology
 *    Project     : dti uart vip
 *    Author      : Lam Pham Ngoc
 *    Module/Class: dti_uart_virtual_sequencer
 *    Create Date : Jul 03 2024
 *    Last Update : Jul 03 2024
 *    Description : UART virtual sequencer
 ******************************************************************************
  History:

 ******************************************************************************/

class dti_uart_virtual_sequencer extends uvm_virtual_sequencer;

  // UART configuration
  dti_uart_configuration  uart_cfg;

  // UART TX sequencer collection.
  dti_uart_tx_sequencer   tx_seqr;

  // UART RX sequencer collection.
  dti_uart_rx_sequencer   rx_seqr;

  `uvm_component_utils(dti_uart_virtual_sequencer)

  extern function      new(string name, uvm_component parent);
  extern function void connect_phase(uvm_phase phase);
endclass

// Function: new
// Constructor of object.
function dti_uart_virtual_sequencer::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

// Function: connect_phase
// UVM built-in method.
function void dti_uart_virtual_sequencer::connect_phase(uvm_phase phase);
  super.connect_phase(phase);

  if (uart_cfg == null)
    `uvm_fatal("connect_phase", "Virtual sequencer cannot get env configuration object")
endfunction
