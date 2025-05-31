/*
 *-----------------------------------------------------------------------------
 *     Copyright (C) 2016 by Dolphin Technology
 *     All right reserved.
 *
 *     Copyright Notification
 *     No part may be reproduced except as authorized by written permission.
 *
 *     Module/Class: dti_cmd_dec_ddrx
 *     Project     : dti_gf28slpd4lp4_phy
 *     Author      : truong
 *     Created     : 02/01/16 16:41:01
 *     Description :
 *
 *     @Last Modified by  : truong
 *     @Last Modified time: 02-01-2016 16:41:03
 *-----------------------------------------------------------------------------
 */
typedef class dti_sysclk_seqr;
typedef class dti_sysclk_seq_item;

class dti_sysclk_seq extends uvm_sequence #(dti_sysclk_seq_item);
  `uvm_object_utils(dti_sysclk_seq)
  `uvm_declare_p_sequencer(dti_sysclk_seqr)
  //---------------------------------------------------------------------------
  //  Public Properties
  //---------------------------------------------------------------------------

  //---------------------------------------------------------------------------
  //  Public Methods
  //---------------------------------------------------------------------------
  function new(string name = "dti_sysclk_seq");
    super.new(name);
  endfunction //  new

endclass  //  dti_sysclk_seq
