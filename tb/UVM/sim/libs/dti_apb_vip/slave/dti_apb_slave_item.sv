/*******************************************************************************
 *    Copyright (C) 2023 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_apb_slave_item.sv
 *    Company     : Dolphin Technology
 *    Project     : dti_apb_vip
 *    Author      : phuongnd0
 *    Module/Class: dti_apb_slave_item
 *    Create Date : Sep 11th 2023
 *    Last Update : Sep 11th 2023
 *    Description : APB slave item
 ******************************************************************************
  History:

 ******************************************************************************/


class dti_apb_slave_item extends dti_apb_item;

  // UVM Factory Registration Macro
  `uvm_object_utils(dti_apb_slave_item)

  int timeout = 0;

  // // Wait delay
  // rand int slave_item_delay[];

  // constraint delay_default {
  //   slave_item_delay.size() == burst_len;
  //   foreach (slave_item_delay[i])
  //     soft slave_item_delay[i] == 0;
  // }

  // Standard UVM Methods:
  extern function new(string name = "dti_apb_slave_item");

endclass

function dti_apb_slave_item::new(string name = "dti_apb_slave_item");
  super.new(name);
endfunction

