//------------------------------------------------------------ 
//   Copyright 2010 Mentor Graphics Corporation 
//   All Rights Reserved Worldwide 
// 
//   Licensed under the Apache License, Version 2.0 (the 
//   "License"); you may not use this file except in 
//   compliance with the License.  You may obtain a copy of 
//   the License at 
// 
//       http://www.apache.org/licenses/LICENSE-2.0 
// 
//   Unless required by applicable law or agreed to in 
//   writing, software distributed under the License is 
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR 
//   CONDITIONS OF ANY KIND, either express or implied.  See 
//   the License for the specific language governing 
//   permissions and limitations under the License. 
//------------------------------------------------------------ 
// 
// Class Description: 
// 
// 
class dti_apb_slave_driver extends uvm_driver#(dti_apb_slave_item); 
 
  // UVM Factory Registration Macro 
  `uvm_component_utils(dti_apb_slave_driver) 
 
  // Virtual Interface 
  virtual dti_apb_slave_intf slave_intf; 
 
  dti_apb_slave_item item; 
 
  //------------------------------------------ 
  // Data Members 
  //------------------------------------------ 
  dti_apb_config apb_cfg; 
  dti_apb_slave_config scfg; 
 
  /** Slave memory 
   *  
   *  Using associative array, as normal array isn't enough to hold 2^32 datas 
   *  (maximum can be used is 2^30) 
   * */ 
  dti_apb_data_t slave_mem[dti_apb_addr_t] = '{default: 'hx}; 
 
  // Standard UVM Methods: 
  extern function new(string name = "dti_apb_slave_driver", uvm_component parent = null); 
  extern task run_phase(uvm_phase phase); 
  extern function void build_phase(uvm_phase phase); 
 
  extern task drive(); 
  extern task check_reset(); 
  extern function bit is_valid_address(dti_apb_addr_t addr); 
  protected process drv_proc; 
 
  /** Write to slave memory */ 
  extern function void write_data(dti_apb_data_t data, dti_apb_addr_t addr, dti_apb_strb_t strb); 
 
  /** Read from slave memory */ 
  extern function dti_apb_data_t read_data(dti_apb_addr_t addr, bit do_rand = 0); 
 
endclass: dti_apb_slave_driver 
 
function dti_apb_slave_driver::new(string name = "dti_apb_slave_driver", uvm_component parent = null); 
  super.new(name, parent); 
endfunction 
 
//pragma protect begin_protected
//pragma protect encrypt_agent="NCPROTECT"
//pragma protect encrypt_agent_info="Encrypted using API"
//pragma protect key_keyowner=Cadence Design Systems.
//pragma protect key_keyname=CDS_KEY
//pragma protect key_method=RC5
//pragma protect key_block
Srp+lnuJPyaD34CVTUjdX6XVvgpj+PpkNIxM+0o/Ir/ZsWi3jnyaGrSE3NNfe2JW
7iDOXNIA+lEteJ1qOI7eFjwdG8KXXZxFpqkWYZcGkhFgDoPmOWuyJ7/zzDMUMw4u
3zJWgS1QX6t3bK1cLlK+qn1dMfBc4pSiCece/YGy3HM5FHBPuSP/HA==
//pragma protect end_key_block
//pragma protect digest_block
hr/av6Q0OKA5+BqGYHhM0YyARHQ=
//pragma protect end_digest_block
//pragma protect data_block
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
//pragma protect end_data_block
//pragma protect digest_block
ZlU7Nd1rGTHy696qPQiE7TlEIBg=
//pragma protect end_digest_block
//pragma protect end_protected
