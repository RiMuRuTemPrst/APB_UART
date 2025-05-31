/*******************************************************************************
 *    Copyright (C) 2024 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_uart_rx_if.sv
 *    Company     : Dolphin Technology
 *    Project     : dti uart vip
 *    Author      : Lam Pham Ngoc
 *    Module/Class: dti_uart_rx_if
 *    Create Date : Jul 03 2024
 *    Last Update : Jul 03 2024
 *    Description : UART RX interface
 ******************************************************************************
  History:

 ******************************************************************************/

interface dti_uart_rx_if ();
  logic clk;
  logic reset_n;
  logic rts_n;
  logic uart_rx;

  // Debug interface
  uart_data_frame_t uart_frame_rx;

  clocking driver_cb @(posedge clk);
    default input #0 output #0;
    output rts_n;
    input  uart_rx;
  endclocking

  modport driver_mp (
    output rts_n,
    input  uart_rx
  );

endinterface : dti_uart_rx_if