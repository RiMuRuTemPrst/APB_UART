/******************************************************************************* 
 *    Copyright (C) 2023 by Dolphin Technology 
 *    All right reserved. 
 * 
 *    Copyright Notification 
 *    No part may be reproduced except as authorized by written permission. 
 * 
 *    File Name   : dti_apb_master_monitor.sv 
 *    Company     : Dolphin Technology 
 *    Project     : dti_apb_vip 
 *    Author      : phuongnd0 
 *    Module/Class: dti_apb_master_monitor 
 *    Create Date : Sep 11th 2023 
 *    Last Update : Sep 11th 2023 
 *    Description :  
 ****************************************************************************** 
  History: 
 
 ******************************************************************************/ 
 
 
class dti_apb_master_monitor extends uvm_component; 
 
  // UVM Factory Registration Macro 
  `uvm_component_utils(dti_apb_master_monitor) 
 
  // Virtual Interface 
  virtual dti_apb_master_intf intf; 
 
  // Master config 
  dti_apb_master_config    mcfg; 
 
  //------------------------------------------ 
  // Data Members 
  //------------------------------------------ 
  int apb_index = 0; // Which PSEL line is this monitor connected to 
  //------------------------------------------ 
  // Component Members 
  //------------------------------------------ 
  uvm_analysis_port #(dti_apb_master_item) ap; 
 
  //------------------------------------------ 
  // Methods 
  //------------------------------------------ 
 
  // Standard UVM Methods: 
 
  extern function new(string name = "dti_apb_master_monitor", uvm_component parent = null); 
  extern function void  build_phase(uvm_phase phase); 
  extern function void  connect_phase(uvm_phase phase); 
  extern task           run_phase(uvm_phase phase); 
  extern function void  report_phase(uvm_phase phase); 
 
endclass: dti_apb_master_monitor 
 
function dti_apb_master_monitor::new(string name = "dti_apb_master_monitor", uvm_component parent = null); 
  super.new(name, parent); 
endfunction 
 
function void dti_apb_master_monitor::build_phase(uvm_phase phase); 
  ap = new("ap", this); 
endfunction: build_phase 
 
function void dti_apb_master_monitor::connect_phase(uvm_phase phase); 
  intf = mcfg.master_intf; 
endfunction : connect_phase 
 
//pragma protect begin_protected
//pragma protect encrypt_agent="NCPROTECT"
//pragma protect encrypt_agent_info="Encrypted using API"
//pragma protect key_keyowner=Cadence Design Systems.
//pragma protect key_keyname=CDS_KEY
//pragma protect key_method=RC5
//pragma protect key_block
hig3rsYRCwYpy1qQLF85o78n37Pec3/5Ua6ri6SgS54sHCoqcfqaokkX+dGpun/g
sJ5ntzfAVEgJHKr8Lb+FATE+/Va50gzB4lCy3qrqM+mXAWW2Yqs6sItHhb1zgRr0
tVxXASzZtuTGdhsqZggnmb6NMwclVGoGZLxMJH0tEyFXh7NAlrNW5Q==
//pragma protect end_key_block
//pragma protect digest_block
wsYAbYP2z/akzUiRk/7VZFTkOxs=
//pragma protect end_digest_block
//pragma protect data_block
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
TKeyVQzx7PEhYALAHDWHTg==
//pragma protect end_data_block
//pragma protect digest_block
u9fu65mkD/vS5CXW5Rh/rJyf4Mc=
//pragma protect end_digest_block
//pragma protect end_protected
