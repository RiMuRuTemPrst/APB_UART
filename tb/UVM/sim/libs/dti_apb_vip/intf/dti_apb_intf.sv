/*******************************************************************************
 *    Copyright (C) 2023 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_apb_intf.sv
 *    Company     : Dolphin Technology
 *    Project     : dti_apb_vip
 *    Author      : phuongnd0
 *    Module/Class: dti_apb_intf
 *    Create Date : Sep 11th 2023
 *    Last Update : Sep 11th 2023
 *    Description : APB interface (both master and slave)
 ******************************************************************************
  History:

 ******************************************************************************/

interface dti_apb_intf();

  logic PCLK;
  logic PRESETn;

  dti_apb_master_intf master_intf();
  dti_apb_slave_intf  slave_intf();

  assign master_intf.PCLK = PCLK;
  assign slave_intf.PCLK = PCLK;
 
  assign master_intf.PRESETn = PRESETn;
  assign slave_intf.PRESETn = PRESETn;

  function virtual dti_apb_master_intf get_master_intf();
    return master_intf;
  endfunction

  function virtual dti_apb_slave_intf get_slave_intf();
    return slave_intf;
  endfunction
endinterface