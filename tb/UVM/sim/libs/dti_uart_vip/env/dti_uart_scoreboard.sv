/*******************************************************************************
 *    Copyright (C) 2024 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_uart_scoreboard.sv
 *    Company     : Dolphin Technology
 *    Project     : dti uart vip
 *    Author      : Lam Pham Ngoc
 *    Module/Class: dti_uart_scoreboard
 *    Create Date : Jul 03 2024
 *    Last Update : Jul 03 2024
 *    Description : UART scoreboard
 ******************************************************************************
  History:

 ******************************************************************************/

`uvm_analysis_imp_decl(_port_tx)
`uvm_analysis_imp_decl(_port_rx)

class dti_uart_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(dti_uart_scoreboard)

  dti_uart_configuration uart_cfg;

  //creating a queue to perform FIFO operation
  dti_uart_tx_transaction tx_item_q[$];
  dti_uart_rx_transaction rx_item_q[$];

  uvm_analysis_imp_port_tx #(dti_uart_tx_transaction, dti_uart_scoreboard) analysis_imp_tx;
  uvm_analysis_imp_port_rx #(dti_uart_rx_transaction, dti_uart_scoreboard) analysis_imp_rx;

  //-----------------------------------------------------------------------------
  // Constructor: new
  // Initializes the config_template class object
  //
  // Parameters:
  //  name - instance name of the config_template
  //  parent - parent under which this component is created
  //-----------------------------------------------------------------------------
  function new(string name="dti_uart_scoreboard",uvm_component parent);
    super.new(name,parent);
  endfunction 


  //-----------------------------------------------------------------------------
  // phase:build
  // This will execute all its methods in zero simulation time
  //-----------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    analysis_imp_tx = new("analysis_imp_tx", this);
    analysis_imp_rx = new("analysis_imp_rx", this);
  endfunction


  //---------------------------------------
  // write task - recives the item from monitor and pushes into queue
  //---------------------------------------
  virtual function void write_port_tx(dti_uart_tx_transaction item);
    // item.print();
    tx_item_q.push_back(item);
  endfunction : write_port_tx


  //---------------------------------------
  // write task - recives the item from monitor and pushes into queue
  //---------------------------------------
  virtual function void write_port_rx(dti_uart_rx_transaction item);
    // item.print();
    rx_item_q.push_back(item);
  endfunction : write_port_rx


  //------------------------------------------------------------------------------
  // phase:run
  // In this task we are trying to get transactions and pushing them into the queue
  //-------------------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    dti_uart_tx_transaction tx_item;
    dti_uart_rx_transaction rx_item;

    forever begin
      wait(tx_item_q.size() > 0 && rx_item_q.size() > 0);
      tx_item = tx_item_q.pop_front();
      rx_item = rx_item_q.pop_front();
      if (tx_item.uart_tx_data_frame !== rx_item.uart_rx_data_frame) begin
        `uvm_error("uart_scoreboard", $sformatf("Data mismatch. Data from TX = 0x%0h Data from RX = 0x%0h", tx_item.uart_tx_data_frame, rx_item.uart_rx_data_frame))
      end
      else begin
        `uvm_info("uart_scoreboard", $sformatf("Succesful comparision. Data from TX = 0x%0h Data from RX = 0x%0h", tx_item.uart_tx_data_frame, rx_item.uart_rx_data_frame), UVM_NONE)
      end
    end

  endtask

endclass
