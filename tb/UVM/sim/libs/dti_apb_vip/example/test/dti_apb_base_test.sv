/*******************************************************************************
 *    Copyright (C) 2023 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_apb_base_test.sv
 *    Company     : Dolphin Technology
 *    Project     : dti_apb_vip
 *    Author      : phuongnd0
 *    Module/Class: dti_apb_base_test
 *    Create Date : Sep 11th 2023
 *    Last Update : Sep 11th 2023
 *    Description : Base test class for APB
 ******************************************************************************
  History:

 ******************************************************************************/

class dti_apb_base_test extends uvm_test;
  `uvm_component_utils(dti_apb_base_test)

  dti_apb_env                 env;
  dti_apb_virtual_sequencer   vseqr;
  dti_apb_config              apb_cfg;
  
  virtual dti_apb_intf        vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  /** Build phase */
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Initialize a test cfg item
    apb_cfg = dti_apb_config::type_id::create("apb_cfg");
    
    if (!uvm_config_db#(virtual dti_apb_intf)::get(null, get_full_name(), "dti_apb_intf", vif))
      `uvm_fatal("get_intf", "no interface found!")

    // Get interface
    apb_cfg.apb_intf = vif;

    // Create sub configs
    apb_cfg.create_sub_configs();
    uvm_config_db#(dti_apb_config)::set(null, "uvm_test_top", "apb_cfg", apb_cfg);
    
    uvm_config_db#(virtual dti_apb_master_intf)::set(null, "uvm_test_top", "master_intf", vif.master_intf);
    uvm_config_db#(virtual dti_apb_slave_intf)::set(null, "uvm_test_top", "slave_intf", vif.slave_intf);

    // Initialize env
    env = dti_apb_env::type_id::create("env", this);
    
  endfunction

  function void connect_phase(uvm_phase phase);
    // Assign virtual sequencer
    vseqr = env.apb_virtual_seqr;
  endfunction
endclass