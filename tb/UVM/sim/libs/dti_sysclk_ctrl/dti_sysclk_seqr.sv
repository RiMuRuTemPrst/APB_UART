/*
 *-----------------------------------------------------------------------------
 *     Copyright (C) 2016 by Dolphin Technology
 *     All right reserved.
 *
 *     Copyright Notification
 *     No part may be reproduced except as authorized by written permission.
 *
 *     Module/Class: dti_sysclk_seqr
 *     Project     : dti_tm28md4lp4_sys
 *     Author      : Truong Nguyen
 *     Created     : 2016-03-05 11:04:18
 *     Description :
 *
 *     @Last Modified by:   Truong Nguyen
 *     @Last Modified time: 2016-03-05 18:08:27
 *-----------------------------------------------------------------------------
 */
typedef class dti_sysclk_seq_item;

class dti_sysclk_seqr extends uvm_sequencer #(dti_sysclk_seq_item);
  `uvm_component_utils(dti_sysclk_seqr)

  //---------------------------------------------------------------------------
  //  Methods
  //---------------------------------------------------------------------------
  /*  Function  : new, Constructor
   *  Arguments
   *    name    : string, Instance's Name
   *
   *  Return    : None
   */
  function new(string name="dti_sysclk_seqr", uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass
