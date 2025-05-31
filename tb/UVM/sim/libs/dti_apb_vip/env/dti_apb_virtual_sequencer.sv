/*******************************************************************************
 *    Copyright (C) 2023 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_apb_virtual_sequencer.sv
 *    Company     : Dolphin Technology
 *    Project     : dti_apb_vip
 *    Author      : phuongnd0
 *    Module/Class: dti_apb_virtual_sequencer
 *    Create Date : Sep 11th 2023
 *    Last Update : Sep 11th 2023
 *    Description : APB Virtual sequencer
 ******************************************************************************
  History:

 ******************************************************************************/

class dti_apb_virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(dti_apb_virtual_sequencer)

  dti_apb_master_sequencer  master_seqr;
  dti_apb_slave_sequencer   slave_seqr;

  dti_apb_config            cfg;

  function new(string name, uvm_component parent);
    super.new(name, parent);

    // if (!uvm_config_db#(apb_config)::get(null,"uvm_test_top","cfg",cfg))
    //   `uvm_fatal("set_config", "no config found! from virtual sequencer")

  endfunction
endclass