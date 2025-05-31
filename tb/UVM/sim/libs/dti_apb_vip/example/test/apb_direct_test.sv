/*******************************************************************************
 *    Copyright (C) 2023 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : apb_direct_test.sv
 *    Company     : Dolphin Technology
 *    Project     : dti_apb_vip
 *    Author      : phuongnd0
 *    Module/Class: apb_direct_test
 *    Create Date : Sep 11th 2023
 *    Last Update : Sep 11th 2023
 *    Description : APB direct test
 ******************************************************************************
  History:

 ******************************************************************************/

class apb_direct_test extends dti_apb_base_test;
  `uvm_component_utils(apb_direct_test)

  function new(string name = "apb_direct_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction

  task run_phase(uvm_phase phase);
    apb_direct_vseq seq_direct = apb_direct_vseq::type_id::create("seq_direct");
    
    phase.raise_objection(this);
      seq_direct.start(env.apb_virtual_seqr);
    phase.drop_objection(this);

  endtask
endclass