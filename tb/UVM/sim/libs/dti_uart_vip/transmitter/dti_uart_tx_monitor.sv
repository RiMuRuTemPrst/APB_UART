/*******************************************************************************
 *    Copyright (C) 2024 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_uart_tx_monitor.sv
 *    Company     : Dolphin Technology
 *    Project     : dti uart vip
 *    Author      : Lam Pham Ngoc
 *    Module/Class: dti_uart_tx_monitor
 *    Create Date : Jul 03 2024
 *    Last Update : Jul 03 2024
 *    Description : UART TX monitor
 ******************************************************************************
  History:

 ******************************************************************************/

class dti_uart_tx_monitor extends uvm_monitor;

  // UART TX interface
  virtual dti_uart_tx_if tx_if;

  // UART TX configuration
  dti_uart_configuration uart_tx_cfg;

  // Analysis port out from monitor.
  uvm_analysis_port #(dti_uart_tx_transaction) out_monitor_port;

  realtime bit_time;

  `uvm_component_utils(dti_uart_tx_monitor)

  extern                   function      new(string name, uvm_component parent);
  extern           virtual function void build_phase(uvm_phase phase);
  extern           virtual function void connect_phase(uvm_phase phase);
  extern           virtual task          run_phase(uvm_phase phase);
  
endclass : dti_uart_tx_monitor


// Function: new
// Constructor of object.
function dti_uart_tx_monitor::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

//pragma protect begin_protected
//pragma protect encrypt_agent="NCPROTECT"
//pragma protect encrypt_agent_info="Encrypted using API"
//pragma protect key_keyowner=Cadence Design Systems.
//pragma protect key_keyname=CDS_KEY
//pragma protect key_method=RC5
//pragma protect key_block
UfycUbAOd/yehImBAXpUTEvbdeteLBDaZkmVp3+RTLMwfgBuVsn98vdSXfjORtIp
Er0uH8EEIxajlqA401zcK0ZPNtMci5bq671oxumUdtAqioSpQk1K3Q8U2nVxEZ+f
XhRu/8nlPhsYbkACAgmD+5NL3kx09VEzxiJobIn9ThxmQ/vt6tarjw==
//pragma protect end_key_block
//pragma protect digest_block
2lcW+6BAGgHUICeCePlJRDH0esk=
//pragma protect end_digest_block
//pragma protect data_block
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
trtwNC61LyxHFGP4/t8+lQ==
//pragma protect end_data_block
//pragma protect digest_block
QR0ediutjT2TpitxHfg2zRXHk1M=
//pragma protect end_digest_block
//pragma protect end_protected
