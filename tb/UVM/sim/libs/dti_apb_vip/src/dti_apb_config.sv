/*******************************************************************************
 *    Copyright (C) 2023 by Dolphin Technology
 *    All right reserved.
 *
 *    Copyright Notification
 *    No part may be reproduced except as authorized by written permission.
 *
 *    File Name   : dti_apb_config.sv
 *    Company     : Dolphin Technology
 *    Project     : dti_apb_vip
 *    Author      : phuongnd0
 *    Module/Class: dti_apb_config
 *    Create Date : Sep 11th 2023
 *    Last Update : Sep 21st 2023
 *    Description : APB system configuration
 ******************************************************************************
  History:
    Sep 21st 2023: modify number of wait states for master and slave

 ******************************************************************************/

class dti_apb_config extends uvm_object;

  /** APB interface */
  virtual dti_apb_intf apb_intf;
  virtual dti_apb_master_intf master_intf;
  virtual dti_apb_slave_intf  slave_intf;
  bit master_en = 1;

  bit slave_en  = 1;

  int max_burst_len = 20;

  int max_master_wait_state = 3;
  int max_slave_wait_state = 0;

  dti_apb_master_config master_cfg;
  dti_apb_slave_config slave_cfg;

  `uvm_object_utils_begin(dti_apb_config)
    `uvm_field_int (master_en,  UVM_ALL_ON)
    `uvm_field_int (slave_en,   UVM_ALL_ON)
  `uvm_object_utils_end

  /** Constructor */
  extern function new(string name = "dti_apb_config");

  /** Create masters and slaves config */
  extern function void create_sub_configs();

endclass

// Constructor
function dti_apb_config::new(string name = "dti_apb_config");
  super.new(name);
endfunction

//pragma protect begin_protected
//pragma protect encrypt_agent="NCPROTECT"
//pragma protect encrypt_agent_info="Encrypted using API"
//pragma protect key_keyowner=Cadence Design Systems.
//pragma protect key_keyname=CDS_KEY
//pragma protect key_method=RC5
//pragma protect key_block
0gCOPJncExrf3nD0Kx+L06H7mf0Pd+59+5aGO16F1zdQQcsO4rKk+3pBA2rDCJcm
hQAnAwqV/p2wmra2hhN4MoOc7acD1TpQt6iOIZVYK9QZQeWc94XLh66Ix7HdF/Mo
cabJRP5Hp8eK0JRRUgnag8vgtPJ41wLZJx+Vsf1eGHKepiHo3lXhJw==
//pragma protect end_key_block
//pragma protect digest_block
wE498OmXQGwR5MJ4uCtQ2DcQRSE=
//pragma protect end_digest_block
//pragma protect data_block
tvtR+sRGtHbumpQFQFy8TbmdjHpp7orirGd/oVXfssboH+Uqtm3ERiXvq7JJWl00
LpYLygPE7EA6TqSQTxlBGcHKEX/U5pbrPngAVSINs+aRocAPwX8CADrZnKbrsB9N
2G8bTONo9hryrBM4yYo7s1s5GmgMLWY2ayHFYpVqJkG7PTE1HoNsABrFE7uQfJtK
TVHxFR6JimZEXlSazrW+hD5yOXhLpS7v1pWpOuX2vWV+evYdD1ybCQr9egcGjI3t
GifWYCSsIHko5hSkEe2kYlzCIbtSz7Lykl7tC9epDgXTzIJmexzNkvlmaXFKL5Ka
idgOaDcm8C0R5OqLLHKsA7kNCA1fEEPpJxD5J5MNZE2FJNB0GulcaHTv+NDgyAc3
vMNKB5huVzA3jIOqisHdTT23GyE6ev38FT1Uib5JGS+2x+EOKQUxhfHx60Coduct
XA4LUlQeQG6CPaxvf9K9VKdvgD+BxeLy9xCRzoMPLMl0iqutzXnzz4MHnjvw1SPb
Gd1usrea6MilqkfY5AAHOWbKy0vJXTA+pvTjQWU2WfNajPmLucMBTt0dMlBO2YVE
gzBBwSLPUSelhYyTIBdtmWc28GNW+lHrD0l1NJ5Wjj2OGlf9+QhCeUNptqp2gNNQ
+fRmev6tt5ZtlD+FOXh3492UrUCd4XUhC2hcW3o9xXZtHEa/mNB8tIkyt0CKBLvu
cNUr57MQ1tviWhgq76+JS5c/hJNTfYqe+O2ixXC/q9AVIjTfnHnf2kV8PK6TlKQw
pITCWVKvFqsmyB8WakYG4Fu0fXtZbnYvbZnRuN5d9H6bfk/y/Ub3APkJT4AATFqm
HCJsnt5X2WSIayvLhApvlhr1FUOO99q5DatDHJKSCJvk2V11STNdBoveOzfAqoqe
BDHTwgSQ2ilTWN5Sq68+DrOkBijkqpYQUdxYtQg5PAMkiAQzhMabOr4AYn53Sm8a
LWve0j9b7cUsnZ2wigVmglk9BjAC3xOV9xlMk5pt7aSubQrMJJ2rpBqxNVkV9str
c1+nLKu9CKlBfB6wDnNuUx77PBgb2cMdRNI2YSTGJ6QhIG0gSu8lswEGsxkkwXdc
f8tgTiysCut+EeDKU6FU6cE78d+11Pm5trOF+XXW+VTfTi4mZfp5AOZ2JyUGniaK
3hKtb2IpedbgZeszXuNyDw==
//pragma protect end_data_block
//pragma protect digest_block
IyYAvW6tE16nYSFvBFI0X1koUhs=
//pragma protect end_digest_block
//pragma protect end_protected
