/*******************************************************************************
 *    Copyright (C) 2023 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_apb_master_intf.sv
 *    Company     : Dolphin Technology
 *    Project     : dti_apb_vip
 *    Author      : phuongnd0
 *    Module/Class: dti_apb_master_intf
 *    Create Date : Sep 11th 2023
 *    Last Update : Sep 11th 2023
 *    Description : APB master interface
 ******************************************************************************
  History:

 ******************************************************************************/
`include "../inc/dti_apb_macros.svh"

interface dti_apb_master_intf(); 

  logic                         PCLK;
  logic                         PRESETn;
  logic [`APB_ADDR_WIDTH-1:0]   PADDR;
  logic [`APB_DATA_WIDTH-1:0]   PRDATA;
  logic [`APB_DATA_WIDTH-1:0]   PWDATA;
  logic [`APB_STRB_WIDTH-1:0]   PSTRB;
  logic                         PSEL;
  logic                         PENABLE;
  logic                         PWRITE;
  logic                         PREADY;
  logic                         PSLVERR;

  modport m_drv_intf (
    input   PCLK,
    input   PRESETn,
    input   PREADY,
    input   PRDATA,
    input   PSLVERR,  
    output  PADDR, 
    output  PWDATA, 
    output  PSTRB, 
    output  PSEL, 
    output  PENABLE, 
    output  PWRITE
  );

endinterface