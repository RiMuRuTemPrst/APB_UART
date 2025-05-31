/*******************************************************************************
 *    Copyright (C) 2024 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_apb_reg_adapter.sv
 *    Company     : Dolphin Technology
 *    Project     : ucie_controller
 *    Author      : phuongnd0
 *    Module/Class: dti_apb_reg_adapter
 *    Create Date : 2024-07-02
 *    Last Update : 2024-07-02
 *    Description : APB reg adapter
 ******************************************************************************
  History:
  2024/07/25: lampn0
    line 42: apb_strb[0]   == (rw.kind == UVM_WRITE) ? '1 : '0; ==> apb_strb[0]   == ((rw.kind == UVM_WRITE) ? '1 : '0);

 ******************************************************************************/

class dti_apb_reg_adapter extends uvm_reg_adapter;
  `uvm_object_utils(dti_apb_reg_adapter)
  int number_of_reg_config = 1;
  extern function                   new(string name = "dti_apb_reg_adapter");
  extern function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
  extern function void              bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
endclass

/** Constructor */
function dti_apb_reg_adapter::new(string name="dti_apb_reg_adapter");
  super.new(name);
endfunction

/** convert reg2bus function */
function uvm_sequence_item dti_apb_reg_adapter::reg2bus(const ref uvm_reg_bus_op rw);
  automatic dti_apb_master_item reg_item = dti_apb_master_item::type_id::create("reg_item");
  void'(reg_item.randomize() with { burst_len     == 1;
                                    apb_addr[0]   == rw.addr;
                                    apb_data[0]   == rw.data;
                                    apb_write[0]  == (rw.kind == UVM_WRITE);
                                    apb_strb[0]   == ((rw.kind == UVM_WRITE) ? '1 : '0);
                                    is_reg_item   == 1;
                                  });

  `uvm_info ("adapter", $sformatf ("reg2bus addr=0x%0h data=0x%0h kind=%s", reg_item.apb_addr[0], reg_item.apb_data[0], rw.kind.name()), UVM_DEBUG)
  return reg_item;
endfunction

/** convert bus2reg function */
function void dti_apb_reg_adapter::bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
  automatic dti_apb_master_item item;

  if (!$cast(item, bus_item))
    `uvm_fatal("bus2reg", "Provided bus_item is not of the correct type")

  rw.kind = item.apb_write[0] ? UVM_WRITE : UVM_READ;
  rw.addr = item.apb_addr[0];
  rw.data = item.apb_data[0];
  rw.status = (item.rw_error[0]) ? UVM_NOT_OK : UVM_IS_OK;
  `uvm_info ("adapter", $sformatf ("bus2reg addr=0x%0h data=0x%0h kind=%s status=%s", rw.addr, rw.data, rw.kind.name(), rw.status.name()), UVM_DEBUG)

endfunction