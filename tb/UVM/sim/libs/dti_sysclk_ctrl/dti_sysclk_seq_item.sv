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

class dti_sysclk_seq_item extends uvm_sequence_item;
  `uvm_object_utils(dti_sysclk_seq_item)
  //---------------------------------------------------------------------------
  //  Public Properties
  //---------------------------------------------------------------------------
  rand  time  duration  ;   //  Duration of current item in ps

  //---------------------------------------------------------------------------
  //  Randomization Constraints
  //---------------------------------------------------------------------------
  // constraint  DURATION  { soft duration == 0; }

  //---------------------------------------------------------------------------
  //  Public Methods
  //---------------------------------------------------------------------------
  function new(string name = "dti_sysclk_seq_item");
    super.new(name);
  endfunction //  new

  virtual function string toString();
    return "Base dti_sysclk_seq_item";
  endfunction

endclass  //  dti_sysclk_seq_item
