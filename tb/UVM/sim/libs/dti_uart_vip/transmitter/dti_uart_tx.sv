/*******************************************************************************
 *    Copyright (C) 2024 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_uart_tx.sv
 *    Company     : Dolphin Technology
 *    Project     : dti uart vip
 *    Author      : Lam Pham Ngoc
 *    Module/Class: dti_uart_tx
 *    Create Date : Jul 03 2024
 *    Last Update : Jul 03 2024
 *    Description : UART TX Agent
 ******************************************************************************
  History:

 ******************************************************************************/

class dti_uart_tx extends uvm_agent;
  // UART configuration object.
  dti_uart_configuration  uart_tx_cfg;

  // UART TX sequencer.
  dti_uart_tx_sequencer   sequencer;

  // UART TX driver.
  dti_uart_tx_driver      driver;

  // UART TX monitor.
  dti_uart_tx_monitor     monitor;

  // UART TX functional coverage collector.
  // dti_uart_coverage          coverage;

  // UART TX throughput analyzer.
  // dti_uart_analyzer          analyzer;

  `uvm_component_utils(dti_uart_tx)

  extern         function      new(string name, uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
endclass

// Function: new
// Constructor of object.
function dti_uart_tx::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

//pragma protect begin_protected
//pragma protect encrypt_agent="NCPROTECT"
//pragma protect encrypt_agent_info="Encrypted using API"
//pragma protect key_keyowner=Cadence Design Systems.
//pragma protect key_keyname=CDS_KEY
//pragma protect key_method=RC5
//pragma protect key_block
8Zc1kwTG4ka8MCB9DDmOnDUfkAclGIPYw+MywP2mUGB3LQb8aVqsmZVX31Oxu2aR
SnIAU2N8nbnme4w+wMvek6W1xUpKXEvehGh7i8wVCRPpto7acKK7WhPFlffELurR
BBz6/umBPoCIIRXVs1PzEvA5t9yzIZYqtZJPiMxSFNs5IRNrldiQEA==
//pragma protect end_key_block
//pragma protect digest_block
9fTEcZxDiEYGSAbn2UDVQO+R9GQ=
//pragma protect end_digest_block
//pragma protect data_block
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
//pragma protect end_data_block
//pragma protect digest_block
I/RBnVaog2Df0vNTvwezH7qOHsA=
//pragma protect end_digest_block
//pragma protect end_protected
