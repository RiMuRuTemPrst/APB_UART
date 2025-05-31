/*******************************************************************************
 *    Copyright (C) 2023 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_apb_master_agent.sv
 *    Company     : Dolphin Technology
 *    Project     : dti_apb_vip
 *    Author      : phuongnd0
 *    Module/Class: dti_apb_master_agent
 *    Create Date : Sep 11th 2023
 *    Last Update : Sep 11th 2023
 *    Description : APB master agent
 ******************************************************************************
  History:

 ******************************************************************************/


class dti_apb_master_agent extends uvm_agent;

  /** Component instances */
  dti_apb_master_driver    driver;
  dti_apb_master_sequencer sequencer;
  dti_apb_master_monitor   monitor;
  // dti_apb_coverage_monitor coverage;

  dti_apb_master_config    master_cfg;

  // UVM Factory Registration Macro
  `uvm_component_utils_begin(dti_apb_master_agent)
  `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
  `uvm_component_utils_end

  // virtual dti_apb_master_intf       master_intf;

  //------------------------------------------
  // Methods
  //------------------------------------------

  // Standard UVM Methods:
  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

endclass: dti_apb_master_agent

function dti_apb_master_agent::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void dti_apb_master_agent::build_phase(uvm_phase phase);
  super.build_phase(phase);

  monitor   = dti_apb_master_monitor::type_id::create("monitor", this);
  if (is_active == UVM_ACTIVE) begin
    sequencer = dti_apb_master_sequencer::type_id::create("sequencer", this);
    driver    = dti_apb_master_driver::type_id::create("driver", this);
  end
  // coverage    = dti_apb_coverage_monitor::type_id::create("coverage", this);

  if (!uvm_config_db#(dti_apb_master_config)::get(null, get_full_name(), "master_cfg", master_cfg))
    `uvm_fatal("build_phase", "Cannot get master configuration");

  monitor.mcfg = master_cfg;
  if (is_active == UVM_ACTIVE) begin
    driver.mcfg = master_cfg;
  end
endfunction: build_phase

function void dti_apb_master_agent::connect_phase(uvm_phase phase);
  if (is_active == UVM_ACTIVE) begin
    driver.master_intf = master_cfg.master_intf;
    driver.seq_item_port.connect(sequencer.seq_item_export);
  end
  // monitor.ap.connect(coverage.analysis_export);
endfunction: connect_phase
