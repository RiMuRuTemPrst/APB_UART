/*******************************************************************************
 *    Copyright (C) 2024 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_uart_rx_driver.sv
 *    Company     : Dolphin Technology
 *    Project     : dti uart vip
 *    Author      : Lam Pham Ngoc
 *    Module/Class: dti_uart_rx_driver
 *    Create Date : Jul 03 2024
 *    Last Update : Jul 03 2024
 *    Description : UART rx driver
 ******************************************************************************
  History:

 ******************************************************************************/

class dti_uart_rx_driver extends uvm_driver #(dti_uart_rx_transaction);
  
  // UART rx interface
  virtual dti_uart_rx_if rx_if;

  // UART rx configuration
  dti_uart_configuration uart_rx_cfg;

  bit parity;

  realtime bit_time;

  `uvm_component_utils(dti_uart_rx_driver)

  extern                   function      new(string name, uvm_component parent);
  extern           virtual function void build_phase(uvm_phase phase);
  extern           virtual function void connect_phase(uvm_phase phase);
  extern           virtual task          run_phase(uvm_phase phase);
  
endclass : dti_uart_rx_driver


// Function: new
// Constructor of object.
function dti_uart_rx_driver::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

//pragma protect begin_protected
//pragma protect encrypt_agent="NCPROTECT"
//pragma protect encrypt_agent_info="Encrypted using API"
//pragma protect key_keyowner=Cadence Design Systems.
//pragma protect key_keyname=CDS_KEY
//pragma protect key_method=RC5
//pragma protect key_block
3wGMWcrGKAf7KYFSwSN0PqrELM5vBzQjbzcE8BATHoHaI0FyD7XproQO3CWzRVVI
C0SlXhvozoJzCAeUZzqG+WzFeLr5+TKEOuAFrqy5xMBIZPNzdQDs78oGo2nvCUqT
Mre02ya+dbQ0PKGsIFosCE6ZkWdNZrfXSMqvHDKxkRn/xcZH0lR4/A==
//pragma protect end_key_block
//pragma protect digest_block
fMKDYLfnZha7h3H7+LhdpDrmN8A=
//pragma protect end_digest_block
//pragma protect data_block
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
//pragma protect end_data_block
//pragma protect digest_block
R5l+CrpSVWTsJxa06OkN32SKafc=
//pragma protect end_digest_block
//pragma protect end_protected
