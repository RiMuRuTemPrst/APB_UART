/*******************************************************************************
 *    Copyright (C) 2023 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_apb_slave_seq_base.sv
 *    Company     : Dolphin Technology
 *    Project     : dti_apb_vip
 *    Author      : phuongnd0
 *    Module/Class: dti_apb_slave_seq_base
 *    Create Date : Sep 11th 2023
 *    Last Update : Sep 11th 2023
 *    Description : APB Slave base sequence
 ******************************************************************************
  History:

 ******************************************************************************/

class dti_apb_slave_seq_base extends uvm_sequence #(dti_apb_slave_item);
  // UVM Factory Registration Macro
  `uvm_object_utils(dti_apb_slave_seq_base)
  `uvm_declare_p_sequencer(dti_apb_slave_sequencer)

  // Standard UVM Methods:
  function new(string name = "dti_apb_slave_seq_base");
    super.new(name);
  endfunction

  virtual task body();
  endtask

endclass:dti_apb_slave_seq_base
