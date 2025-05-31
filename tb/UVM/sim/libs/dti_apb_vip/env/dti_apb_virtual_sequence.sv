/*******************************************************************************
 *    Copyright (C) 2023 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_apb_virtual_sequence.sv
 *    Company     : Dolphin Technology
 *    Project     : dti_apb_vip
 *    Author      : phuongnd0
 *    Module/Class: dti_apb_virtual_sequence
 *    Create Date : Sep 11th 2023
 *    Last Update : Sep 11th 2023
 *    Description : APB Virtual sequence
 ******************************************************************************
  History:

 ******************************************************************************/

class dti_apb_virtual_sequence extends uvm_sequence;
  `uvm_object_utils(dti_apb_virtual_sequence)
  `uvm_declare_p_sequencer(dti_apb_virtual_sequencer)

  function new(string name="dti_apb_virtual_sequence");
    super.new(name);
  endfunction

endclass
 