/*******************************************************************************
 *    Copyright (C) 2024 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_uart_random_test.sv
 *    Company     : Dolphin Technology
 *    Project     : dti uart vip
 *    Author      : Lam Pham Ngoc
 *    Module/Class: dti_uart_random_test
 *    Create Date : Jul 03 2024
 *    Last Update : Jul 03 2024
 *    Description : UART test top
 ******************************************************************************
  History:

 ******************************************************************************/

class dti_uart_random_test extends dti_uart_base_test;

  `uvm_component_utils(dti_uart_random_test)

  dti_uart_tx_seq tx_seq;
  dti_uart_rx_seq rx_seq;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  virtual task run_phase(uvm_phase phase);
    tx_seq = dti_uart_tx_seq::type_id::create("tx_seq",this);
    rx_seq = dti_uart_rx_seq::type_id::create("rx_seq",this);
    phase.raise_objection(this);
    fork
      rx_seq.start(env.uart_rx.sequencer);
      begin
        #1
        tx_seq.start(env.uart_tx.sequencer);
      end
    join

    #50;
    phase.drop_objection(this);

    //set a drain-time for the environment if desired
    phase.phase_done.set_drain_time(this, 100);

  endtask : run_phase

endclass