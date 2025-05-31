/******************************************************************************* 
 *    Copyright (C) 2023 by Dolphin Technology 
 *    All right reserved. 
 * 
 *    Copyright Notification 
 *    No part may be reproduced except as authorized by written permission. 
 * 
 *    File Name   : dti_apb_master_driver.sv 
 *    Company     : Dolphin Technology 
 *    Project     : dti_apb_vip 
 *    Author      : phuongnd0 
 *    Module/Class: dti_apb_master_driver 
 *    Create Date : Sep 11th 2023 
 *    Last Update : Sep 11th 2023 
 *    Description : APB master driver 
 ****************************************************************************** 
  History: 
  07/25/2024: lampn0 - Reset_n is required when start run_phase 
 
 ******************************************************************************/ 
 
class dti_apb_master_driver extends uvm_driver #(dti_apb_master_item); 
 
  // UVM Factory Registration Macro 
  `uvm_component_utils(dti_apb_master_driver) 
 
  // Virtual Interface 
  virtual dti_apb_master_intf master_intf; 
 
  dti_apb_master_item item; 
  int item_count = 0; 
  protected process drv_proc; 
  int time_get_item; 
 
  //------------------------------------------ 
  // Config 
  //------------------------------------------ 
  dti_apb_config apb_cfg; 
  dti_apb_master_config mcfg; 
 
  // Standard UVM Methods: 
  extern function new(string name = "dti_apb_master_driver", uvm_component parent = null); 
  extern task run_phase(uvm_phase phase); 
  extern function void build_phase(uvm_phase phase); 
 
  extern task drive(); 
  extern task check_reset(); 
 
endclass: dti_apb_master_driver 
 
// new 
function dti_apb_master_driver::new(string name = "dti_apb_master_driver", uvm_component parent = null); 
  super.new(name, parent); 
endfunction 
 
// run phase 
task dti_apb_master_driver::run_phase(uvm_phase phase); 
  // reset 
  @(negedge master_intf.PRESETn); 
  // if (master_intf.PRESETn) begin 
    master_intf.PSEL = 0; 
    master_intf.PENABLE <= 0; 
    master_intf.PADDR <= 0; 
    master_intf.PSTRB <= 0; 
    master_intf.PWRITE <= 0; 
    master_intf.PWDATA <= 0;   
  // end 
  @(posedge master_intf.PRESETn) 
  @(posedge master_intf.PCLK); 
 
  item = dti_apb_master_item::type_id::create("item"); 
  fork 
    check_reset(); 
  join_none 
 
  forever begin 
    while (~master_intf.PRESETn) 
      @(posedge master_intf.PCLK); 
    seq_item_port.get_next_item(item); 
    time_get_item = $time; 
 
    fork  
      drive(); 
      check_reset(); 
    join_any 
    disable fork; 
 
    // if (item.is_reg_item) begin // put response if item is reg 
      // rsp = dti_apb_master_item::type_id::create("rsp"); 
      // rsp.set_id_info(item); 
      // rsp.copy(item); 
      // seq_item_port.put_response(rsp); 
    // $display("%0d master: item_reg_done", $time); 
    // end 
    seq_item_port.item_done(); 
    // $display("%0d master: item done", $time); 
  end 
 
endtask: run_phase 
 
//pragma protect begin_protected
//pragma protect encrypt_agent="NCPROTECT"
//pragma protect encrypt_agent_info="Encrypted using API"
//pragma protect key_keyowner=Cadence Design Systems.
//pragma protect key_keyname=CDS_KEY
//pragma protect key_method=RC5
//pragma protect key_block
gSArtAOt+Q0aEHz5oYMr9YLWic4N28UFK/y4tee9p7d6b4P6iKWlechGCTKxfG1O
Gdr8hT7Ki07QiZp2Oxk82I9f/IVoNulPtWscl0d3SzK20EqwH3NcreZ5LOAKVb1g
hWnXKzE8uG8o8igm76o8ZYmZdBaCyxr331rY0zFJpi6y30ot6LxR3w==
//pragma protect end_key_block
//pragma protect digest_block
NQXjtdJn7XS4JQNOt6eu6mwQQyY=
//pragma protect end_digest_block
//pragma protect data_block
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
//pragma protect end_data_block
//pragma protect digest_block
t9duP/MJZCYafsEWh4HcbM3/dus=
//pragma protect end_digest_block
//pragma protect end_protected
