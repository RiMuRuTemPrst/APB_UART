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
// Functional coverage monitor for the APB agent
//
// Collects basic coverage information
//
class dti_apb_coverage_monitor extends uvm_subscriber #(dti_apb_master_item);

// UVM Factory Registration Macro
//
`uvm_component_utils(dti_apb_coverage_monitor)


//------------------------------------------
// Cover Group(s)
//------------------------------------------
covergroup apb_cov;
  CVP_WRITE: coverpoint analysis_txn.apb_write[0] {
    bins write = {1};
    bins read = {0};
  }

  CVP_STRB: coverpoint analysis_txn.apb_strb[0] {
    bins all = {4'b1111};
  }
// To do:
// Monitor is not returning delay info
endgroup

//------------------------------------------
// Component Members
//------------------------------------------
dti_apb_master_item analysis_txn;

//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:

extern function new(string name = "dti_apb_coverage_monitor", uvm_component parent = null);
extern function void write(dti_apb_master_item t);
extern function void report_phase(uvm_phase phase);

endclass: dti_apb_coverage_monitor

function dti_apb_coverage_monitor::new(string name = "dti_apb_coverage_monitor", uvm_component parent = null);
  super.new(name, parent);
  apb_cov = new();
endfunction

function void dti_apb_coverage_monitor::write(dti_apb_master_item t);
  analysis_txn = t;
  apb_cov.sample();
endfunction:write

function void dti_apb_coverage_monitor::report_phase(uvm_phase phase);
// Might be a good place to do some reporting on no of analysis transactions sent etc

endfunction: report_phase
