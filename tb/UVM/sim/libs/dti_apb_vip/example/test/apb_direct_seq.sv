/*******************************************************************************
 *    Copyright (C) 2023 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : apb_direct_seq.sv
 *    Company     : Dolphin Technology
 *    Project     : dti_apb_vip
 *    Author      : phuongnd0
 *    Module/Class: 
 *    Create Date : Sep 11th 2023
 *    Last Update : Sep 11th 2023
 *    Description : APB direct sequences
 ******************************************************************************
  History:

 ******************************************************************************/

class apb_master_direct_seq extends dti_apb_master_seq_base;
  `uvm_object_utils(apb_master_direct_seq)

  dti_apb_master_item item;

  function new(string name = "apb_master_direct_seq");
    super.new(name);
  endfunction

  virtual task body();
    item = dti_apb_master_item::type_id::create("item");
    `uvm_do_with(item, {item.apb_addr[0] == 32'h0000_FA00; item.apb_write[0] == 1; burst_len == 1;})

    `uvm_do_with(item, {burst_len == 4; 
                        item.apb_addr[0] == 32'h0000_FA00; item.apb_write[0] == 1; 
                        item.apb_addr[1] == 32'h00FA_FA00; item.apb_write[1] == 1;
                        item.apb_addr[2] == 32'h00FF_FA00; item.apb_write[2] == 1;
                        item.apb_addr[3] == 32'h00AA_FA00; item.apb_write[3] == 1;
                        })

    // `uvm_do_with(item, {item.apb_addr == 32'h0000_FA00; item.apb_write == 0; burst_len == 1;})
    // `uvm_do_with(item, {item.apb_addr == 32'h00FA_FA00; item.apb_write == 0; burst_len == 1;})
    // `uvm_do_with(item, {item.apb_addr == 32'h00FF_FA00; item.apb_write == 0; burst_len == 1;})
    // `uvm_do_with(item, {item.apb_addr == 32'h00AA_FA00; item.apb_write == 0; burst_len == 1;})
  endtask
endclass

class apb_slave_direct_seq extends dti_apb_slave_seq_base;
  `uvm_object_utils(apb_slave_direct_seq)
  dti_apb_slave_item item;

  function new(string name = "apb_slave_direct_seq");
    super.new(name);
  endfunction

  virtual task body();
    item = dti_apb_slave_item::type_id::create("item");
    forever begin
      `uvm_do(item)
    end
  endtask
endclass

class apb_direct_vseq extends dti_apb_virtual_sequence;
  `uvm_object_utils(apb_direct_vseq)
  function new(string name = "apb_direct_vseq");
    super.new(name);
  endfunction

  virtual task body();
    apb_master_direct_seq master_req_seq0 = new("master_req_seq0");
    apb_slave_direct_seq slave_resp_seq0  = new("slave_resp_seq0");
    fork
      master_req_seq0.start(p_sequencer.master_seqr);
      slave_resp_seq0.start(p_sequencer.slave_seqr);
    join_any
    #10;
  endtask
endclass