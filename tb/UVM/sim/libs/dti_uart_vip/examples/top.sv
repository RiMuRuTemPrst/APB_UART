/*******************************************************************************
 *    Copyright (C) 2024 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : top.sv
 *    Company     : Dolphin Technology
 *    Project     : dti uart vip
 *    Author      : Lam Pham Ngoc
 *    Module/Class: test_top
 *    Create Date : Jul 03 2024
 *    Last Update : Jul 03 2024
 *    Description : top testbench
 ******************************************************************************
  History:

 ******************************************************************************/

`timescale 1ns/1ps

`include "include_files.sv"

module test_top;

  reg clk;
  reg reset_n;

  dti_uart_tx_if tx_if();
  dti_uart_rx_if rx_if();

  assign tx_if.clk = clk;
  assign tx_if.reset_n = reset_n;

  assign rx_if.clk = clk;
  assign rx_if.reset_n = reset_n;

  assign tx_if.cts_n = rx_if.rts_n;
  assign rx_if.uart_rx = tx_if.uart_tx;

  initial begin
    uvm_config_db#(virtual dti_uart_tx_if)::set(uvm_root::get(), "uvm_test_top", "tx_if", tx_if);
    uvm_config_db#(virtual dti_uart_rx_if)::set(uvm_root::get(), "uvm_test_top", "rx_if", rx_if);
    run_test("dti_uart_random_test");
  end

  always #10 clk = ~clk;

  initial begin
    clk = 1'bx;
    reset_n = 1'bx;
    #26;
    clk = 1'b0;
    reset_n = 1'b1;
    #29;
    reset_n = 1'b0;
    #29;
    reset_n = 1'b1;
    #29;
  end

endmodule : test_top