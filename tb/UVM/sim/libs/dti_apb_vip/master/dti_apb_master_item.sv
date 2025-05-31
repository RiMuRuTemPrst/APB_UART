/*******************************************************************************
 *    Copyright (C) 2023 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_apb_master_item.sv
 *    Company     : Dolphin Technology
 *    Project     : dti_apb_vip
 *    Author      : phuongnd0
 *    Module/Class: dti_apb_master_item
 *    Create Date : Sep 11th 2023
 *    Last Update : Sep 11th 2023
 *    Description : APB master item
 ******************************************************************************
  History:

 ******************************************************************************/


class dti_apb_master_item extends dti_apb_item;

  // UVM Factory Registration Macro
  `uvm_object_utils(dti_apb_master_item)

  // Wait delay
  rand int master_item_delay[];

  // Read/Write error
  rand bit rw_error[];

  // Register item
  rand bit is_reg_item;

  constraint delay_default {
    soft is_reg_item == 0;
    soft master_item_delay.size() == burst_len;
    soft rw_error.size() == burst_len;
    foreach (master_item_delay[i])
      soft master_item_delay[i] == 0;
  }

  // Standard UVM Methods:
  extern function new(string name = "dti_apb_master_item");
endclass

function dti_apb_master_item::new(string name = "dti_apb_master_item");
  super.new(name);
endfunction

