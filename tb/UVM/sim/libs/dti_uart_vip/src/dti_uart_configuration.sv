/*******************************************************************************
 *    Copyright (C) 2024 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_uart_configuration.sv
 *    Company     : Dolphin Technology
 *    Project     : dti uart vip
 *    Author      : Lam Pham Ngoc
 *    Module/Class: dti_uart_configuration
 *    Create Date : Jul 03 2024
 *    Last Update : Jul 03 2024
 *    Description : UART configuration
 ******************************************************************************
  History:

 ******************************************************************************/

class dti_uart_configuration extends uvm_object;

  // UART TX interface
  virtual dti_uart_tx_if tx_if;

  // UART RX interface
  virtual dti_uart_rx_if rx_if;

  // Frequency (MHz)
  int fCK_MHz = 50;

  // Frequency (ns)
  real tCK_ns = 20;

  // Baudrate
  int baudrate = `UART_BAUDRATE_9600;

  // Bit rate (ns)
  int bit_rate;

  // The number of data bits
  data_bit_num_e data_bit_num = UART_8BIT;

  // The number of stop bits
  stop_bit_num_e stop_bit_num = UART_ONE_STOP_BIT;

  // Parity enable
  parity_en_e parity_en = UART_PARITY_EN;

  // Parity type select
  parity_type_e parity_type = UART_PARITY_EVEN;

  // When agent set to ACTIVE the sequencer and driver will be worked.
  // Otherwise only monitor is working.
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  `uvm_object_utils_begin(dti_uart_configuration)
    `uvm_field_int         (                          fCK_MHz,        UVM_ALL_ON)
    `uvm_field_real        (                          tCK_ns,         UVM_ALL_ON)
    `uvm_field_int         (                          baudrate,       UVM_ALL_ON)
    `uvm_field_int         (                          bit_rate,       UVM_ALL_ON)
    `uvm_field_enum        (data_bit_num_e,           data_bit_num,   UVM_ALL_ON)
    `uvm_field_enum        (stop_bit_num_e,           stop_bit_num,   UVM_ALL_ON)
    `uvm_field_enum        (parity_en_e,              parity_en,      UVM_ALL_ON)
    `uvm_field_enum        (parity_type_e,            parity_type,    UVM_ALL_ON)
    `uvm_field_enum        (uvm_active_passive_enum,  is_active,      UVM_ALL_ON)
  `uvm_object_utils_end

  extern function new(string name="dti_uart_configuration");

  //----------------------------------------------------------------------------
  /**
   * This function sets tCK timing parameter depending on fCK
   */
  extern virtual function void randomize_tCK_ns();

  //----------------------------------------------------------------------------
  /**
   * This function sets fCK timing parameter depending on tCK
   */
  extern virtual function void randomize_fCK_MHz();

  //----------------------------------------------------------------------------
  /**
   * This function sets bit_rate timing parameter depending on tCK and fCK
   */
  extern virtual function void randomize_bit_rate();

endclass : dti_uart_configuration


// Function: new
// Constructor of object.
function dti_uart_configuration::new(string name="dti_uart_configuration");
  super.new(name);
endfunction

//pragma protect begin_protected
//pragma protect encrypt_agent="NCPROTECT"
//pragma protect encrypt_agent_info="Encrypted using API"
//pragma protect key_keyowner=Cadence Design Systems.
//pragma protect key_keyname=CDS_KEY
//pragma protect key_method=RC5
//pragma protect key_block
rkV7g1OS9H5lKOpWDrXaa6TDz4NTyVwAmk/LstZJx/OSonLxFPZ+AQ8v3WzJtQk4
NiM5XXVo8YOokVT7m2jAunT7Ki43Uwx8OH44hZP2B8gMXXVdMyXZ5s2SvUnUt4vV
C9U6ZT2lJVmwInynYXYeT4vYXyL7MTY48GK+blRW2T9G75S1/B9Ohw==
//pragma protect end_key_block
//pragma protect digest_block
cUnxWuOKr4sgoA/UCYg64HwNxl0=
//pragma protect end_digest_block
//pragma protect data_block
nesN+jzH6k3XonL++nsnj2f2CbzaE4QmoIUCwlOkPiiFqy0qehLsTQj7pHCkNLlw
6xhN0KkbEHGyCLxG+Y1saQlqtX8E3xZo3UYMFkh5/KQ/H349x42YYx6TW6NfHvsv
noOPsoctKgv9rc9JAsZDLroZKGwcK8nP07apikJiC4yp//qkEa/wRIdD9xjoSi08
pyW8fSoHmOPxQMWDUa6y+HH6zce+5I8zn7SVo4RSg+58fys8QWxMrs04LcArvkfs
b/iRZe19qLH0wE38skfd2GXrMhngssMOo7trXt60IAQA3i83d/p0mgi2w6KZ2VB0
S0B/PaQ/eJrnWDFrLeO+JrgGrhV3gtXR2e1BN+7s5hydAUaG2OTC+VjXKz9hBj9e
CgllpStuVwWhNvZRR1vn/W1pbxqLjE/+pu1EyjHx3+aAf+t0TglBxPCR41YJB4LI
/8/B6MJFdKoK8f9KXXUfTTHqIh81sFAeADjBQbG6VAQj63Or1QspYC7iIP4pVMdu
u6h6KMxMWWQTi4P6RKNVm0NyWje7uwnk80F48XDU3mELjVWa/fxyIG5m4mc6Ifxq
zMxjp2gmMeUnwdXeYKDtZhtRKlJW3+LoT79VVLDdc1ynAcWujoodNqQBSoQgotz9
5AvIsoWCSBmZ9BqqTM/ETzT8jn1W9ffQrxkKMAB6qNzAyMU16cWFySBhsbo39ESr
EFA6IykZ+izIk7erG2v7x8DeRjbQoPftRxYKpOCLJY2mWOKVv9Y8x1sTi2Zj0501
6FzmLFsZgUJtB4MQHldDHsOg7UUVuZ6q1ntwfeOhmnwLZ38BqRDEVkQscDD9H9k5
FswjTmyVyg52Hj/w4wt9L2kCKy2hBsO5FH9ZR9eif2lGiKNVNlOTmwaF/zKbdGFE
4HPdBra97TGUgihDqFpMbEyCj0jwvR+vrYXmgj2SOzX7GRlNy0GV4ijaXFUgq3Hd
4Uuc7/SZOtaJCKW3qyMaGBbk+xfqHPwOjojrfdhSapLLseYgF/pDjWcXNStMPJH/
OaSNtVEgjKR2ZLuD0LuVLfgj/vZmn3O9rvLWwUrf2C8R48gHOX4fsEo+ymNGCDiq
Tms05cWKH8s7V/m2ib3xlPrvZ+oiOKvJFfW76rf4I8aVdF089PqSkjHRP+IeEu9w
LMRaDD1lcOEULoNcXNKOT9djIdIwYNEMzlVZo6SIFmLvtKV0yiIw1siAtHKgNPR8
xrkKEqAINxLlj0q7HJZEB8nNMWl9rejwzf1v/71jcuAUu/tG74W1fVqbRcj+Mcck
hz8D+GcSETxRJC05L+DCO0D+0dcQTOu2X6CCpHGMwJ6mMkR1jH2aYB/0tncZ5n/5
eRNRYCnCmyMEk5OFqA1lNa8voR+UHSu3p+0XB8CQ76jRRwpCQxrqsGQisijJRQ5L
5f+gOpUdExnVLKTeYwSlLOOc/V6W1rJ+VPV3jWGPACQ=
//pragma protect end_data_block
//pragma protect digest_block
xTbLhrGRQGawSP8RWqOhVkA1js4=
//pragma protect end_digest_block
//pragma protect end_protected
