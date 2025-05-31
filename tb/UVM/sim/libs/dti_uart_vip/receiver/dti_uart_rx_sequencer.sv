/*******************************************************************************
 *    Copyright (C) 2024 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_uart_rx_sequencer.sv
 *    Company     : Dolphin Technology
 *    Project     : dti uart vip
 *    Author      : Lam Pham Ngoc
 *    Module/Class: dti_uart_rx_sequencer
 *    Create Date : Jul 03 2024
 *    Last Update : Jul 03 2024
 *    Description : UART rx sequencer
 ******************************************************************************
  History:

 ******************************************************************************/

class dti_uart_rx_sequencer extends uvm_sequencer #(dti_uart_rx_transaction);

  // UART rx configuration object.
  dti_uart_configuration uart_rx_cfg;

  `uvm_component_utils(dti_uart_rx_sequencer)

  extern                   function      new(string name, uvm_component parent);
  extern           virtual function void build_phase(uvm_phase phase);
endclass

// Function: new
// Constructor of object.
function dti_uart_rx_sequencer::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction


// Function: build_phase
// UVM built-in method.
function void dti_uart_rx_sequencer::build_phase(uvm_phase phase);
  super.build_phase(phase);

  // Get the cfg object
  if (!uvm_config_db #(dti_uart_configuration)::get(null, get_full_name(), "uart_rx_cfg", uart_rx_cfg) && uart_rx_cfg == null)
    `uvm_fatal("build_phase", "Cannot get UART RX configuration in sequencer")
endfunction
