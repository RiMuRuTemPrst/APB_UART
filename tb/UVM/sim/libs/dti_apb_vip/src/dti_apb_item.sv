/*******************************************************************************
 *    Copyright (C) 2023 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_apb_item.sv
 *    Company     : Dolphin Technology
 *    Project     : dti_apb_vip
 *    Author      : phuongnd0
 *    Module/Class: dti_apb_item
 *    Create Date : Sep 11th 2023
 *    Last Update : Sep 11th 2023
 *    Description : apb item
 ******************************************************************************
  History:

 ******************************************************************************/

class dti_apb_item extends uvm_sequence_item;
  /** APB data */
  rand dti_apb_data_t apb_data[];
  // rand dti_apb_data_t apb_rdata[];

  /** APB address */
  rand dti_apb_addr_t apb_addr[];

  /** Direction: read or write */
  rand logic          apb_write[];

  /** Strobe - byte lanes */
  rand dti_apb_strb_t apb_strb[];

  /** */
  rand int burst_len;

  /** Utility macros*/
  `uvm_object_utils_begin(dti_apb_item)
    `uvm_field_array_int ( apb_data,   UVM_ALL_ON)
    `uvm_field_array_int ( apb_addr,    UVM_ALL_ON)
    `uvm_field_array_int ( apb_write,   UVM_ALL_ON)
    `uvm_field_array_int ( apb_strb,    UVM_ALL_ON)
    `uvm_field_int ( burst_len,   UVM_ALL_ON)
  `uvm_object_utils_end

  extern function new(string name="dti_apb_item");  

  constraint read_strb {
    foreach (apb_strb[i])
      if (apb_write[i] == 0) apb_strb[i] == '0;
    // (apb_write == 0) -> apb_strb == 0;
  }

  constraint default_burst_len {
    soft burst_len == 1;
  }

  constraint array_size {
    apb_data.size()  == burst_len;
    apb_addr.size()  == burst_len;
    apb_write.size() == burst_len;
    apb_strb.size()  == burst_len;
  }
endclass

function dti_apb_item::new(string name="dti_apb_item");  
  super.new(name);
endfunction


