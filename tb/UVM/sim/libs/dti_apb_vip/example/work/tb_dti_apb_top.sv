/*******************************************************************************
 *    Copyright (C) 2023 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : tb_dti_apb_top.sv
 *    Company     : Dolphin Technology
 *    Project     : dti_apb_vip
 *    Author      : phuongnd0
 *    Module/Class: tb_dti_apb_top
 *    Create Date : Sep 11th 2023
 *    Last Update : Sep 11th 2023
 *    Description : Top testbench for APB VIP
 ******************************************************************************
  History:

 ******************************************************************************/


`include "dti_apb_pkg.svh"
import uvm_pkg::*;
import dti_apb_pkg::*;
`include "apb_direct_seq.sv"
`include "apb_direct_test.sv"

module tb_dti_apb_top;
  dti_apb_intf apb_intf();
  dti_apb_sva apb_sva(.intf(apb_intf.master_intf));
  // dti_wb_intercon wb_intercon(.intf(wb_intf));
  // dti_apb_sva wb_sva(.intf(wb_intf.master_intf[0]));

  assign apb_intf.slave_intf.PADDR    = apb_intf.master_intf.PADDR;
  assign apb_intf.slave_intf.PWDATA   = apb_intf.master_intf.PWDATA;
  assign apb_intf.slave_intf.PWRITE   = apb_intf.master_intf.PWRITE;
  assign apb_intf.slave_intf.PSEL     = apb_intf.master_intf.PSEL;
  assign apb_intf.slave_intf.PENABLE  = apb_intf.master_intf.PENABLE;
  assign apb_intf.slave_intf.PSTRB    = apb_intf.master_intf.PSTRB;
  assign apb_intf.master_intf.PREADY  = apb_intf.slave_intf.PREADY;
  assign apb_intf.master_intf.PRDATA  = apb_intf.slave_intf.PRDATA;
  assign apb_intf.master_intf.PSLVERR = apb_intf.slave_intf.PSLVERR;

  initial begin
    $display("running simulation");

    uvm_config_db#(virtual dti_apb_intf)::set(uvm_root::get(), "uvm_test_top", "dti_apb_intf", apb_intf);
    // uvm_config_db #(int)::dump();
    run_test("apb_direct_test");
    $finish();
  end

  initial begin
    apb_intf.PCLK = 0;
    apb_intf.PRESETn = 1;
    #12 apb_intf.PRESETn = 0;
    #12 apb_intf.PRESETn = 1;
  end

  always #5 apb_intf.PCLK = ~apb_intf.PCLK;
endmodule