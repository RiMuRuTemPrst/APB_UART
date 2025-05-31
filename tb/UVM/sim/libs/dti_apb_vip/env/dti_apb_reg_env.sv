/*******************************************************************************
 *    Copyright (C) 2024 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_apb_reg_env.sv
 *    Company     : Dolphin Technology
 *    Project     : ucie_controller
 *    Author      : phuongnd0
 *    Module/Class: dti_apb_reg_env
 *    Create Date : 2024-05-27
 *    Last Update : 2024-05-27
 *    Description :
 ******************************************************************************
  History:

 ******************************************************************************/

class dti_apb_reg_env extends uvm_env;
  `uvm_component_utils(dti_apb_reg_env)

  dti_apb_master_agent                       apb_agent;
  dti_ucie_reg_adapter                       apb_adapter;
  uvm_reg_predictor #(dti_apb_master_item)   apb_predictor;

  // Define reg block here
  apb_block_regs                             apb_regs;
  extern function new(string name="dti_apb_reg_env", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
endclass

/** Constructor */
function dti_apb_reg_env::new(string name="dti_apb_reg_env", uvm_component parent);
  super.new(name, parent);
endfunction

/** Build phase */
function void dti_apb_reg_env::build_phase(uvm_phase phase);
  super.build_phase(phase);
  apb_regs = ucie_controller_regs::type_id::create($sformatf("apb_regs_%s", this.get_parent().get_name()), this);

  apb_regs.build();
  apb_regs.lock_model();

  uvm_config_db#(ucie_controller_regs)::set(null, "*", $sformatf("apb_regs_%s", this.get_parent().get_name()), apb_regs);

  apb_adapter  = dti_ucie_reg_adapter::type_id::create("apb_adapter");
  apb_predictor= uvm_reg_predictor #(dti_apb_master_item) :: type_id :: create("apb_predictor", this);
endfunction

/** Connect phase */
function void dti_apb_reg_env::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  apb_predictor.map     = apb_regs.default_map;
  apb_predictor.adapter = apb_adapter;
endfunction 