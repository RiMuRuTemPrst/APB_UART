/*******************************************************************************
 *    Copyright (C) 2024 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_uart_tx_if.sv
 *    Company     : Dolphin Technology
 *    Project     : dti uart vip
 *    Author      : Lam Pham Ngoc
 *    Module/Class: dti_uart_tx_if
 *    Create Date : Jul 03 2024
 *    Last Update : Jul 03 2024
 *    Description : UART TX interface
 ******************************************************************************
  History:

 ******************************************************************************/

interface dti_uart_tx_if ();
  logic clk;
  logic reset_n;
  logic cts_n;
  logic uart_tx;

  // Debug interface
  uart_data_frame_t uart_frame_tx;

  clocking driver_cb @(posedge clk);
    default input #0 output #0;
    input  cts_n;
    output uart_tx;
  endclocking

  modport driver_mp (
    input  cts_n,
    output uart_tx
  );

endinterface : dti_uart_tx_if