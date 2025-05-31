/*******************************************************************************
 *    Copyright (C) 2024 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_uart_env.sv
 *    Company     : Dolphin Technology
 *    Project     : dti uart vip
 *    Author      : Lam Pham Ngoc
 *    Module/Class: dti_uart_env
 *    Create Date : Jul 03 2024
 *    Last Update : Jul 03 2024
 *    Description : UART environment
 ******************************************************************************
  History:

 ******************************************************************************/

class dti_uart_env extends uvm_env;

  // UART configuration
  dti_uart_configuration      uart_cfg;

  // UART TX instances.
  dti_uart_tx                 uart_tx;

  // UART RX instances.
  dti_uart_rx                 uart_rx;

  // UART sequencer handle.
  dti_uart_virtual_sequencer  virt_seqr;

  dti_uart_scoreboard         scb;

  `uvm_component_utils(dti_uart_env)

  extern                   function      new(string name, uvm_component parent);
  extern virtual           function void build_phase(uvm_phase phase);
  extern virtual           function void connect_phase(uvm_phase phase);
endclass

// Function: new
// Constructor of object.
function dti_uart_env::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

// Function: build_phase
// UVM built-in method.
function void dti_uart_env::build_phase(uvm_phase phase);
  super.build_phase(phase);
  `uvm_info(this.get_full_name(), "Build phase", UVM_HIGH);

  if (!uvm_config_db #(dti_uart_configuration)::get(null, get_full_name(), "uart_cfg", uart_cfg) && uart_cfg == null) begin
    `uvm_fatal("build_phase", "Cannot get env configuration.");
  end

  virt_seqr = dti_uart_virtual_sequencer::type_id::create("virt_seqr", this);

  uart_tx = dti_uart_tx::type_id::create("uart_tx", this);
  uart_rx = dti_uart_rx::type_id::create("uart_rx", this);
  scb = dti_uart_scoreboard::type_id::create("scb", this);

  uvm_config_db #(dti_uart_configuration)::set(this, "uart_tx", "uart_tx_cfg", uart_cfg);
  uvm_config_db #(dti_uart_configuration)::set(this, "uart_rx", "uart_rx_cfg", uart_cfg);

  virt_seqr.uart_cfg = uart_cfg;
endfunction

// Function: connect_phase
// UVM built-in method.
function void dti_uart_env::connect_phase(uvm_phase phase);
  `uvm_info(this.get_full_name(), "Connect phase", UVM_HIGH);
    virt_seqr.tx_seqr = uart_tx.sequencer;
    virt_seqr.rx_seqr = uart_rx.sequencer;
    uart_tx.monitor.out_monitor_port.connect(scb.analysis_imp_tx);
    uart_rx.monitor.out_monitor_port.connect(scb.analysis_imp_rx);
endfunction