/*******************************************************************************
 *    Copyright (C) 2023 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_apb_master_config.sv
 *    Company     : Dolphin Technology
 *    Project     : dti_apb_vip
 *    Author      : phuongnd0
 *    Module/Class: dti_apb_master_config
 *    Create Date : Sep 11th 2023
 *    Last Update : Sep 11th 2023
 *    Description : APB master config
 ******************************************************************************
  History:

 ******************************************************************************/
class dti_apb_master_config extends uvm_object;

  // UVM Factory Registration Macro
  `uvm_object_utils(dti_apb_master_config)

  // Virtual Interface
  virtual dti_apb_master_intf master_intf;

  //------------------------------------------
  // Data Members
  //------------------------------------------
  // Is the agent active or passive
  uvm_active_passive_enum active = UVM_ACTIVE;

  // Include the APB functional coverage monitor
  bit has_functional_coverage = 0;

  // Include the APB RAM based scoreboard
  bit has_scoreboard = 0;

  // Max number of wait states
  int max_wait_state = 3;
  extern function new(string name = "dti_apb_master_config");

endclass: dti_apb_master_config

function dti_apb_master_config::new(string name = "dti_apb_master_config");
  super.new(name);
endfunction
