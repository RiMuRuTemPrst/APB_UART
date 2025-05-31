/*******************************************************************************
 *    Copyright (C) 2023 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_apb_master_sequencer.sv
 *    Company     : Dolphin Technology
 *    Project     : dti_apb_vip
 *    Author      : phuongnd0
 *    Module/Class: dti_apb_master_sequencer
 *    Create Date : Sep 11th 2023
 *    Last Update : Sep 11th 2023
 *    Description : APB Master sequencer
 ******************************************************************************
  History:

 ******************************************************************************/

class dti_apb_master_sequencer extends uvm_sequencer #(dti_apb_master_item);

  // UVM Factory Registration Macro
  `uvm_component_utils(dti_apb_master_sequencer)

  // Standard UVM Methods:
  extern function new(string name, uvm_component parent);

endclass: dti_apb_master_sequencer

function dti_apb_master_sequencer::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction
