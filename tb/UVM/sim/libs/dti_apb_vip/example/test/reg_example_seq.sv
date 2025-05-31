/*******************************************************************************
 *    Copyright (C) 2024 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_ucie_reg_base_seq.sv
 *    Company     : Dolphin Technology
 *    Project     : ucie_controller
 *    Author      : phuongnd0
 *    Module/Class: reg_example_seq
 *    Create Date : 2024-05-24
 *    Last Update : 2024-05-27
 *    Description : APB example sequence
 ******************************************************************************
  History:

 ******************************************************************************/

class reg_example_seq extends dti_ucie_reg_base_seq;
  `uvm_object_utils(reg_example_seq)

  extern function new(string name = "reg_example_seq");
  extern task     body();

endclass

function reg_example_seq::new(string name = "reg_example_seq");
  super.new(name);
endfunction

task reg_example_seq::body();
  // Mode configure
  reg_id      = apb_regs.get_reg_by_name("reg_ucie_link_control");
  field_id    = reg_id.get_field_by_name("target_link_width");
  value       = 4'h2 << field_id.get_lsb_pos();

  field_id    = reg_id.get_field_by_name("target_link_speed");
  value      += 4'h4 << field_id.get_lsb_pos();

  field_id    = reg_id.get_field_by_name("start_ucie_link_training");
  value      += 1'b1 << field_id.get_lsb_pos();

  // Write reg
  write_reg ("reg_ucie_link_control", value, status, UVM_FRONTDOOR);

  // Read reg
  read_reg("reg_ucie_link_control", value, status, UVM_FRONTDOOR);

  // Read reg from reg model
  reg_id      = ucie_regs.get_reg_by_name("reg_ucie_link_control");
  value = reg_id.get("reg_ucie_link_control", 0);
  `uvm_info("REG", $sformatf("reg_ucie_link_control = %0h", value), UVM_DEBUG)

endtask