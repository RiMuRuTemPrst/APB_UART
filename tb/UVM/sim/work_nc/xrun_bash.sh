#!/bin/bash

reset

# UVM
UVMLIB=1800.2-2020.3.0
export UVM_HOME=/tools/uvm/$UVMLIB

export VSM_T=""
export TEST_NAME="apb_uart_standard_test"
function vlb {
  reset; rm -rf INCA_libs xrun.key xrun.log xcelium.d *.err
}

#---------------------------------------------------------------------------------------------------
# Test normal WRITE/READ
#---------------------------------------------------------------------------------------------------
function vsm_i {
 export VSM_T="vsm"
  xrun -messages -l ./log/vsm.log -uvm -uvmhome $UVM_HOME +UVM_TESTNAME=${TEST_NAME} $CMPOPT -f filelist_vsim.f -f filelist_com.f -f filelist_rtl.f -f filelist_tb.f -f xrun_options -covdut apb_uart_top -coverage all -covtest ${TEST_NAME} -covoverwrite -input probe.tcl -write_metrics
}

vlb
vsm_i