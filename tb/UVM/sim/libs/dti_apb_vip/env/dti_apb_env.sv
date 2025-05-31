/*******************************************************************************
 *    Copyright (C) 2023 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_apb_env.sv
 *    Company     : Dolphin Technology
 *    Project     : dti_apb_vip
 *    Author      : phuongnd0
 *    Module/Class: dti_apb_env
 *    Create Date : Sep 11th 2023
 *    Last Update : Sep 11th 2023
 *    Description : APB environment
 ******************************************************************************
  History:

 ******************************************************************************/

class dti_apb_env extends uvm_env;
  `uvm_component_utils(dti_apb_env)

  /** Agent, Scoreboard and Config */
  dti_apb_master_agent  apb_master_agent;
  dti_apb_slave_agent   apb_slave_agent;
  dti_apb_config        apb_cfg;

  /** Virtual sequencer */
  dti_apb_virtual_sequencer   apb_virtual_seqr;

  /** Methods */
  extern function new (string name = "dti_apb_env", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

endclass

function dti_apb_env::new (string name = "dti_apb_env", uvm_component parent);
  super.new(name, parent);
endfunction

function void dti_apb_env::build_phase(uvm_phase phase);
  super.build_phase(phase);
  
  /** Grab user config from database */
  if (!uvm_config_db#(dti_apb_config)::get(null, "uvm_test_top", "apb_cfg", apb_cfg))
    `uvm_fatal("set_config", "no config found!")

  /** Initialize agents */
  // apb_master_agent = new;
  // apb_slave_agent  = new;

  /** Initialize virtual sequencer */
  apb_virtual_seqr = dti_apb_virtual_sequencer::type_id::create("apb_virtual_seqr", this);

  uvm_config_db#(dti_apb_master_config)::set(this, "master", "master_cfg", apb_cfg.master_cfg);
  uvm_config_db#(dti_apb_slave_config)::set(this, "slave" , "slave_cfg", apb_cfg.slave_cfg);

  apb_master_agent  = dti_apb_master_agent::type_id::create("master", this);
  apb_slave_agent   = dti_apb_slave_agent::type_id::create("slave", this);
endfunction

function void dti_apb_env::connect_phase(uvm_phase phase);
  super.connect_phase (phase);
  apb_virtual_seqr.master_seqr  = apb_master_agent.sequencer;
  apb_virtual_seqr.slave_seqr   = apb_slave_agent.sequencer;

  // apb_master_agent.monitor.item_collected_port.connect(apb_scb.item_collected_export);
endfunction