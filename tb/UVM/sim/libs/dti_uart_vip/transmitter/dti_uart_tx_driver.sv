/*******************************************************************************
 *    Copyright (C) 2024 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_uart_tx_driver.sv
 *    Company     : Dolphin Technology
 *    Project     : dti uart vip
 *    Author      : Lam Pham Ngoc
 *    Module/Class: dti_uart_tx_driver
 *    Create Date : Jul 03 2024
 *    Last Update : Jul 03 2024
 *    Description : UART TX driver
 ******************************************************************************
  History:

 ******************************************************************************/

class dti_uart_tx_driver extends uvm_driver #(dti_uart_tx_transaction);
  
  // UART TX interface
  virtual dti_uart_tx_if tx_if;

  // UART TX configuration
  dti_uart_configuration uart_tx_cfg;

  bit parity;

  real bit_time;

  `uvm_component_utils(dti_uart_tx_driver)

  extern                   function      new(string name="dti_uart_tx_driver", uvm_component parent);
  extern           virtual function void build_phase(uvm_phase phase);
  extern           virtual function void connect_phase(uvm_phase phase);
  extern           virtual task          run_phase(uvm_phase phase);

  extern protected virtual task          reset_signal();
  extern protected virtual task          get_and_drive(dti_uart_tx_transaction item);

endclass : dti_uart_tx_driver


// Function: new
// Constructor of object.
function dti_uart_tx_driver::new(string name="dti_uart_tx_driver", uvm_component parent);
  super.new(name, parent);
endfunction

//pragma protect begin_protected
//pragma protect encrypt_agent="NCPROTECT"
//pragma protect encrypt_agent_info="Encrypted using API"
//pragma protect key_keyowner=Cadence Design Systems.
//pragma protect key_keyname=CDS_KEY
//pragma protect key_method=RC5
//pragma protect key_block
vfj6BvEQVNEB53NmR5bYlEcvNSmHvdTU6ZpQyFbqDHHFtklgZlDckA1MKYrQo985
sgb3wqkUO9giSL+zuFrOq+Uo31ktVc+kYrUc00MXadCykA/Z1MqF/VSDt2FSzCQn
SDBnqzmaeqTvFE95LwHIyHUejREsL8UY1MLGGZNqDhw7d1L6evUSIg==
//pragma protect end_key_block
//pragma protect digest_block
GbzYq62obFVNKyFardiFw3Xll/U=
//pragma protect end_digest_block
//pragma protect data_block
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
Ibw/NuJNxRJNnbB21N2UHA==
//pragma protect end_data_block
//pragma protect digest_block
SQWkfdqZ06mItrrkDFZHpU1dCYU=
//pragma protect end_digest_block
//pragma protect end_protected
