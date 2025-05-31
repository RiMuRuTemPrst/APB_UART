/*******************************************************************************
 *    Copyright (C) 2024 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_uart_rx_monitor.sv
 *    Company     : Dolphin Technology
 *    Project     : dti uart vip
 *    Author      : Lam Pham Ngoc
 *    Module/Class: dti_uart_rx_monitor
 *    Create Date : Jul 03 2024
 *    Last Update : Jul 03 2024
 *    Description : UART rx monitor
 ******************************************************************************
  History:

 ******************************************************************************/

class dti_uart_rx_monitor extends uvm_monitor;

  // UART rx interface
  virtual dti_uart_rx_if rx_if;

  // UART rx configuration
  dti_uart_configuration uart_rx_cfg;

  // Analysis port out from monitor.
  uvm_analysis_port #(dti_uart_rx_transaction) out_monitor_port;

  bit parity;

  realtime bit_time;

  `uvm_component_utils(dti_uart_rx_monitor)

  extern                   function      new(string name, uvm_component parent);
  extern           virtual function void build_phase(uvm_phase phase);
  extern           virtual function void connect_phase(uvm_phase phase);
  extern           virtual task          run_phase(uvm_phase phase);
  
endclass : dti_uart_rx_monitor


// Function: new
// Constructor of object.
function dti_uart_rx_monitor::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

//pragma protect begin_protected
//pragma protect encrypt_agent="NCPROTECT"
//pragma protect encrypt_agent_info="Encrypted using API"
//pragma protect key_keyowner=Cadence Design Systems.
//pragma protect key_keyname=CDS_KEY
//pragma protect key_method=RC5
//pragma protect key_block
yCOjWcOF1az8q2f2MnfiM1PWMx9B3EAlVkKGvDOKFCI1dd7uY1M0QeCd0TmqnAeb
HGQjEIFcy0or7WG7RI/gvCbhi3Xq5zKidCn8LGhpyvNkk/YDXr25gWNOWa7V2JJj
tsEhsff4F+CpJpuh3Na7PpkutoyLYETUVCYgV0Vnhy900FgrK3ZAXQ==
//pragma protect end_key_block
//pragma protect digest_block
O2TMFGQq4jQwnV9U7tHq5059IFs=
//pragma protect end_digest_block
//pragma protect data_block
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
//pragma protect end_data_block
//pragma protect digest_block
a8tcwcVLgpBJYdc/llSPhW/fpb4=
//pragma protect end_digest_block
//pragma protect end_protected
