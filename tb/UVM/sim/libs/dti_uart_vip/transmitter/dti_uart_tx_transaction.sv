/*******************************************************************************
 *    Copyright (C) 2024 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_uart_tx_transaction.sv
 *    Company     : Dolphin Technology
 *    Project     : dti uart vip
 *    Author      : Lam Pham Ngoc
 *    Module/Class: dti_uart_tx_transaction
 *    Create Date : Jul 03 2024
 *    Last Update : Jul 03 2024
 *    Description : UART TX transaction
 ******************************************************************************
  History:

 ******************************************************************************/

class dti_uart_tx_transaction extends uvm_sequence_item;
  // UART TX configuration
  dti_uart_configuration uart_tx_cfg;

  rand uart_data_frame_t uart_tx_data_frame;

  `uvm_object_utils_begin(dti_uart_tx_transaction)
    `uvm_field_int      (uart_tx_data_frame, UVM_ALL_ON)
  `uvm_object_utils_end

  extern function      new(string name="dti_uart_tx_transaction");
  extern function void pre_randomize();
  extern function void post_randomize();

endclass : dti_uart_tx_transaction


// Function: new
// Constructor of object.
function dti_uart_tx_transaction::new(string name="dti_uart_tx_transaction");
  super.new(name);
endfunction


//pragma protect begin_protected
//pragma protect encrypt_agent="NCPROTECT"
//pragma protect encrypt_agent_info="Encrypted using API"
//pragma protect key_keyowner=Cadence Design Systems.
//pragma protect key_keyname=CDS_KEY
//pragma protect key_method=RC5
//pragma protect key_block
Ya0EPL0kuDh7rPTe+uAnRtIqUmpESyt94fznZjACHLVvwmcJQMbFq6UIc5orsCLk
irM4N+MPByD0D20IkbF3DVS9VqpbmzH1OKGu0IyLgk2V+9g9/DBpPKgTX7SIrBoS
HaoDJZeZfxfnxHAJ6mAgJUkeAppdk6Ci9wqUdvKxlJ995kOrbPUMGw==
//pragma protect end_key_block
//pragma protect digest_block
JnHphA5uNBziSpdhoXJ5sdi66tc=
//pragma protect end_digest_block
//pragma protect data_block
GyQSHJ1++3AEJVeKR7bxPmM+0J6wgPaKnxoaz5q0MrS6Cx/uyRFh6ADAGwCePgFe
nfIdO9whOR3tf/8WpD7mGpF24L5wjrkcbY5lsCQflZelFB7AK58XdSCuTEf8hD9S
GVO+W8IXnFbficoOZM92SRY0Kty0C/eDB0H0OudU8G9bChM/PFmmDicPWHWyd8ih
CuHQhaOMICCsBTj0no3V7Zg7cxAHwN/VWxRjnmySMSQbto2zowSzXWkIJ/t7IpA/
zIhhzihqCkni/WQWI+d8Hr5jXj4YLDWuf9gyymlys0xFLbhfSgTmvii0L4J1tnXS
xvOvGDrpJNyK4k/oGZjnljIULVmcGC8rwEuKCX514/UCPGeFQRmqs+e9PBjwG609
mZewAlMGyMH1RdHGBJyNCPbps7oGnwEmTsuenn8Y7Gh+kRtFO4VH1RtC13E4ylA0
luPv6853cavh6Qng2eA5VsGa0VcKXKx+FNEXLjV6YVPScbBV0pakmIt9erjRza9D
l3K4m0mKLPhYj+J6NK5tDbfe86UIu/dA27YviwiQ8Yn/nCSwGukg9eNSUIZSO73g
/JLObDDwwb3ix1zgLLKtk5r5EjBetE+XGIMz3YhJghh/p9vEuJdSX/0GzxwuQ/4b
jO6c3inwK/dIOCiSwTvA8x8WB1CduVzbimTQnvZhfHiuwiFnw3c0nivU4uby6f/v
H56Zo5z5USbt/FWK1NcUqwJJSzx5QyzDVaWCSVBI32P8Q0GclJJoukVK3uKM+F5+
pBD/3Bzv8L/D7imsydeErBbB0QgKU8uc7Pa1kThoVwk7EOnSYEgQInRHoCxE1Ews
3BZWRWtIgyE7tOjiFXOFezmy82+b8PsYSY7yNsTCI23+q/chd2MIt+/XCMhIj7A4
QITIGqlIHR1KrU2YZJNYsl/TTEKYrLGkzy/dgUjHlbE+WVzM+rDW5RF/zBzJoyaj
zaHGBjvFYNJP4oUvZPIPscu7bTTuEqRWK4bHbXuidOJbf+rQ6aqjfNLgib2JTAOM
4G091QmHehH8uPG3G+pmKe03X5gRQxNFBgSmxSi8H9TIHmkAia4I1U8VgxdE6IVU
L75EIJr2XLMCBuvfL+rdl33xb5HgZUqNMNkTbEUQAAinA+hECJ/Y1quBz7zofLoO
IKol/aG6kw1S0XqIqvSsbt0ULYRelLjHHEaRBrNj4PEGCTKrZN7UFTbCEZZGp2eJ
AP2l0/6wShQLt/A4ao+oibQwgdPh3uDYDuippVms8Yv4tu/HVR/Bt1hipzWfBnZL
q1SqVM9baUklCTwdGXr3IexoV77vl3WzEjPj4pREOxOmlA+6zyGtw74tDTyifIq1
1o6iB+wF1AOHwkH6CyLU7s9S1g8VQr+5qBh/KH7u72fgvfFoZVXbbUdHSmCHKbQZ
dchbZZ797b02nXvqyKrS+imc544vCUihlgoHDUZMIB87kpzi/P2IEsIwmT+aMf8U
eE2GtV5zNP3ZyCmXd+Kzm6rG0Z9pakDEt1Ly+SYWSyzAN6AQ3mbgvEbcsfTwmvTw
3lk+gPAKRCjggwRJqlXWEkHKa1Z4jg4K2U05JiWNJ3V5LOM3/FES2hiLfVR9L+ok
//pragma protect end_data_block
//pragma protect digest_block
8iPV/lNdMLtSWp6NhQmOiGUxxJc=
//pragma protect end_digest_block
//pragma protect end_protected
