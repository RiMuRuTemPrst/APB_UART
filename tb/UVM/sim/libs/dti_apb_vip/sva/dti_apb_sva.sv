/*******************************************************************************
 *    Copyright (C) 2023 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_apb_sva.sv
 *    Company     : Dolphin Technology
 *    Project     : dti_apb_vip
 *    Author      : phuongnd0
 *    Module/Class: dti_apb_sva
 *    Create Date : Sep 18th 2023
 *    Last Update : Sep 18th 2023
 *    Description : APB SVA
 ******************************************************************************
  History:

 ******************************************************************************/
`include "dti_apb_macros.svh"
module dti_apb_sva(dti_apb_master_intf intf);

  logic                         apb_clk;
  logic                         apb_resetn;
  logic [`APB_ADDR_WIDTH-1:0]   apb_addr;
  logic [`APB_DATA_WIDTH-1:0]   apb_rdata;
  logic [`APB_DATA_WIDTH-1:0]   apb_wdata;
  logic [`APB_STRB_WIDTH-1:0]   apb_strb;
  logic                         apb_sel;
  logic                         apb_enable;
  logic                         apb_write;
  logic                         apb_ready;
  logic                         apb_slverr;

  assign apb_clk    = intf.PCLK;
  assign apb_resetn = intf.PRESETn;
  assign apb_addr   = intf.PADDR;
  assign apb_rdata  = intf.PRDATA;
  assign apb_wdata  = intf.PWDATA;
  assign apb_strb   = intf.PSTRB;
  assign apb_sel    = intf.PSEL;
  assign apb_enable = intf.PENABLE;
  assign apb_write  = intf.PWRITE;
  assign apb_ready  = intf.PREADY;
  assign apb_slverr = intf.PSLVERR;

  property AP_APB_RESET_p;
    @(negedge apb_resetn)
    1'b1 |=> @(posedge apb_clk) (apb_sel == 0 && apb_enable == 0);
  endproperty

  property AP_APB_TRANS_COMPLETE_p;
    @(posedge apb_clk) disable iff (~apb_resetn)
    (apb_ready == 1) |=> (apb_ready == 0);
  endproperty

  property AP_APB_STRB_READ_LOW_p;
    @(posedge apb_clk) disable iff (~apb_resetn)
    (~apb_write) |-> (apb_strb == 0);
  endproperty

  property AP_APB_WDATA_STABLE_p;
    @(posedge apb_clk) disable iff (~apb_resetn)
    (apb_write && apb_enable) |-> $stable(apb_wdata);
  endproperty

  property AP_APB_ADDR_STABLE_p;
    @(posedge apb_clk) disable iff (~apb_resetn)
    (apb_enable) |-> $stable(apb_addr);
  endproperty

  property AP_APB_SEL_STABLE_p;
    @(posedge apb_clk) disable iff (~apb_resetn)
    !apb_sel && $past(apb_sel) |-> $past(apb_enable) && $past(apb_ready); 
  endproperty

  AP_APB_RESET          : assert property (AP_APB_RESET_p);
  // AP_APB_TRANS_COMPLETE : assert property (AP_APB_TRANS_COMPLETE_p);
  AP_APB_STRB_READ_LOW  : assert property (AP_APB_STRB_READ_LOW_p);
  AP_APB_WDATA_STABLE   : assert property (AP_APB_WDATA_STABLE_p);
  AP_APB_ADDR_STABLE    : assert property (AP_APB_ADDR_STABLE_p);
  AP_APB_SEL_STABLE     : assert property (AP_APB_SEL_STABLE_p);
endmodule