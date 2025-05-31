`ifndef __DTI_SYSCLK_PKG__
`define __DTI_SYSCLK_PKG__

package dti_sysclk_pkg;
  import  uvm_pkg::*;
  `include "uvm_macros.svh"
  // `include "dti_global_defines.svh"
  `include "dti_sysclk_macros.svh"

  `include "dti_sysclk_params.svh"
  `include "dti_sysclk_seq_item.sv"
  `include "dti_sysclk_seq.sv"
  `include "dti_sysclk_seqr.sv"
  `include "dti_sysclk_drv.sv"
  `include "dti_sysclk_agent.sv"

  export  uvm_pkg::*;

endpackage

`endif  //  __DTI_SYSCLK_PKG__