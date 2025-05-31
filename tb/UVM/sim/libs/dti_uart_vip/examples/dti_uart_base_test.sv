/*******************************************************************************
 *    Copyright (C) 2024 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_uart_base_test.sv
 *    Company     : Dolphin Technology
 *    Project     : dti uart vip
 *    Author      : Lam Pham Ngoc
 *    Module/Class: dti_uart_base_test
 *    Create Date : Jul 03 2024
 *    Last Update : Jul 03 2024
 *    Description : UART test top
 ******************************************************************************
  History:

 ******************************************************************************/

class dti_uart_base_test extends uvm_test;

  virtual dti_uart_tx_if tx_if;
  virtual dti_uart_rx_if rx_if;

  dti_uart_configuration uart_cfg;

  dti_uart_env env;

  `uvm_component_utils(dti_uart_base_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uart_cfg = dti_uart_configuration::type_id::create("uart_cfg");
    void'(uvm_config_db#(virtual dti_uart_tx_if)::get(null, get_full_name(), "tx_if", tx_if));
    void'(uvm_config_db#(virtual dti_uart_rx_if)::get(null, get_full_name(), "rx_if", rx_if));

    uart_cfg.tx_if = tx_if;
    uart_cfg.rx_if = rx_if;

    uvm_config_db#(dti_uart_configuration)::set(this, "env", "uart_cfg", uart_cfg);
    env = dti_uart_env::type_id::create("env", this);

  endfunction

  virtual function void end_of_elaboration();
    //print's the topology
    print();
  endfunction

endclass