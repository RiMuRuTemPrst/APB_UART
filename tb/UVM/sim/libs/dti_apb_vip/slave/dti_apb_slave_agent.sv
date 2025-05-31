/******************************************************************************* 
 *    Copyright (C) 2023 by Dolphin Technology 
 *    All right reserved. 
 * 
 *    Copyright Notification 
 *    No part may be reproduced except as authorized by written permission. 
 * 
 *    File Name   : dti_apb_master_agent.sv 
 *    Company     : Dolphin Technology 
 *    Project     : dti_apb_vip 
 *    Author      : phuongnd0 
 *    Module/Class: dti_apb_master_agent 
 *    Create Date : Sep 11th 2023 
 *    Last Update : Sep 11th 2023 
 *    Description : APB master agent 
 ****************************************************************************** 
  History: 
 
 ******************************************************************************/ 
 
 
class dti_apb_slave_agent extends uvm_agent; 
 
  // UVM Factory Registration Macro 
  `uvm_component_utils(dti_apb_slave_agent) 
  // uvm_analysis_port #(apb_seq_item) ap; 
 
  /** Component instances */ 
  dti_apb_slave_driver    driver; 
  dti_apb_slave_sequencer sequencer; 
 
  dti_apb_slave_config    slave_cfg; 
 
  // virtual dti_apb_slave_intf       slave_intf; 
 
  //------------------------------------------ 
  // Methods 
  //------------------------------------------ 
 
  // Standard UVM Methods: 
  extern function new(string name, uvm_component parent); 
  extern function void build_phase(uvm_phase phase); 
  extern function void connect_phase(uvm_phase phase); 
 
endclass: dti_apb_slave_agent 
 
 
function dti_apb_slave_agent::new(string name, uvm_component parent); 
  super.new(name, parent); 
endfunction 
 
//pragma protect begin_protected
//pragma protect encrypt_agent="NCPROTECT"
//pragma protect encrypt_agent_info="Encrypted using API"
//pragma protect key_keyowner=Cadence Design Systems.
//pragma protect key_keyname=CDS_KEY
//pragma protect key_method=RC5
//pragma protect key_block
SUpg/bdvmLF6y/zx6+M54W1PvW0AGX2OhVrVrNY0vyZ0l4/DkwqHmZCoOvEGxJB9
NjXN9mP8gKVPdhnz5Xth3zFM3o3Z42o1hXlDcu69ZmG4uENTnsFvePQOzVQarwQR
WTp1rkNWgM51I3XW/HxQ3wlanTZadaFqAFsQfjrdyQmwuiDU+XJZVg==
//pragma protect end_key_block
//pragma protect digest_block
ksAMQ2X3cJfCDGACMS0Wj6+UF7w=
//pragma protect end_digest_block
//pragma protect data_block
QXktGKXyHIatCav78KD9aDUPzlEbDn6Yqjh2W10F3fE04gUcsQ/JcNvRfbmZuLgU
JeclA33t/OLoGaZjRQlP2oD89VMmJprmUhObFTtg8CwpU2wGsDVx6g39vj6ddsEA
Wbqw224uUuKlXYo9oegYEi7+1HX+2xgcDpDLKWKB06ZsHM0ErJoiuDOQiMmJi85C
0uR6MlE8EE3c1eldNqrzW3HZNWlPcrYS/bVAAhAQC5vSQDulezzvRdQu+qJmozH6
SVsR2M90PJdCYCYeb3kvMQe64ZUhUposmKDc5r6VEisTtV8kvpw/y0ytQ0GwEkdr
Qvl+abHAGfdVK3TlZKrDriPaI7KPnU1RtstDA3q2JMlREl7kAS5hrhSutuH/rk5Z
i1Jr4WTWgywB/hBs6z++ZTn9Ib4sJDQpJdkhYZOJCFLoBdAdX0jP8v7B7lDBxdrQ
G/UcUZed9Qibz6WPmxVaepaoAUxZaQsjxWTDxXMrKodLrpoLSXdu3DfENCs52Ied
+r9frFIli/xFW+GiYJ6XJq2MuQvctDOoIWvalQ6vhuZV9Y2s7tnNoUqBUuptwvPN
VTw3nzgZb2BsnViYYaCWNphW/RplO+/yyC8cEeOFjOQa4ew6f2xFE/Fqxs50z7pi
k5//XeHlM3qmUFqpxwFMFb+gTWqBnxUm6OFQ0IwmS4YPBh38+6E8Zkcfc5Dod3n6
CyDEB3LaqWs1w/GNh53fzOqt0cP4I2lYq9X4RS/GpdF2uzHhZXE3gAB+ctvyPKC8
Y+OnfIQ7DaVK4NPFDhw0TEPdYKkJhcvist1I07wkEZBMb+vVPDt3rvKcQE+m7/tZ
eSSQVYGJsXz/9bQGBA97M2dNlrzyDZwugF0sebs1SVQJbNgYUd+U4MDOjbwFcD1m
JrUIbcHgkted/XeuC6yHmMd2fBJ1qXEBtikOO4oqI6SSEX+X80U5smijTeTlIKmo
Y7/P6O45Kmm1T5/01GpaucS3C02d49jrzCSWe9I7P35U/zuValVsXNZljFe7h00t
kEGjzCL4KJNlbbre4zgXlbSFuIOnPQqseyfdjuvaaQ9MICq6iiN7Gm5DVzfzNdME
pjADWLrFDlRAbokB9FkCWe0K1H4kJpmPEk8z3v5gzuls/R11wyE+E/rkOKltDXbG
Q5sNYkwawYjbFfdtx69Snpsigj0rzzJBtrj04Q3H9Aq0pThTxOEz/cfrrqkahHTw
TAOeyoAAkhnysMncKQvnOGzR1ncwYGpsr3NY281Kobc9z9A84ZrFygiDt64FOrEG
jPZgs7B0J6/M8h4jMfgVzk9/sHYWiiPNiRbOq3kzTuwmC05ZYAmBHvusBGFRilLe
OyXXZs04hwCDUIi+XegBSzskug+7ZFQK0piKORI2J0NK4p3pRTn1ZjnVIzlEUril
//pragma protect end_data_block
//pragma protect digest_block
37LRBS2vIxPqNqRyV1uvoWweJng=
//pragma protect end_digest_block
//pragma protect end_protected
