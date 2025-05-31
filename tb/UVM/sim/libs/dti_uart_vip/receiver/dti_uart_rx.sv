/*******************************************************************************
 *    Copyright (C) 2024 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_uart_rx.sv
 *    Company     : Dolphin Technology
 *    Project     : dti uart vip
 *    Author      : Lam Pham Ngoc
 *    Module/Class: dti_uart_rx
 *    Create Date : Jul 03 2024
 *    Last Update : Jul 03 2024
 *    Description : UART rx Agent
 ******************************************************************************
  History:

 ******************************************************************************/

class dti_uart_rx extends uvm_agent;
  // UART configuration object.
  dti_uart_configuration  uart_rx_cfg;

  // UART rx sequencer.
  dti_uart_rx_sequencer   sequencer;

  // UART rx driver.
  dti_uart_rx_driver      driver;

  // UART rx monitor.
  dti_uart_rx_monitor     monitor;

  // UART rx functional coverage collector.
  // dti_uart_coverage          coverage;

  // UART rx throughput analyzer.
  // dti_uart_analyzer          analyzer;

  `uvm_component_utils(dti_uart_rx)

  extern         function      new(string name, uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
endclass

// Function: new
// Constructor of object.
function dti_uart_rx::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

//pragma protect begin_protected
//pragma protect encrypt_agent="NCPROTECT"
//pragma protect encrypt_agent_info="Encrypted using API"
//pragma protect key_keyowner=Cadence Design Systems.
//pragma protect key_keyname=CDS_KEY
//pragma protect key_method=RC5
//pragma protect key_block
rP11nKB3hmewpLlJUPtSLIaLX8gYKzBQK6tXmCTOzL4PpuYC9ZUnJdNWvzVa/dK3
u9NAtn59t12NUv1qNyGg/XhSAeequ2LhK+ID7pe8WFAE9mUvZDlL22iwaRN67rI7
A+vxpLyJ4ue24aA6Q4rMLdI9QEb4zYO7K/cKQMUxIJsehwfH8t8C9w==
//pragma protect end_key_block
//pragma protect digest_block
j+ybHzxHmYqg2/EIYXbLCE+aYII=
//pragma protect end_digest_block
//pragma protect data_block
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
//pragma protect end_data_block
//pragma protect digest_block
kKLdppf/TH9MJOxcV+dvxFnrAmY=
//pragma protect end_digest_block
//pragma protect end_protected
