/*
 *-----------------------------------------------------------------------------
 *     Copyright (C) 2016 by Dolphin Technology
 *     All right reserved.
 *
 *     Copyright Notification
 *     No part may be reproduced except as authorized by written permission.
 *
 *     Module/Class: dti_sysclk_agent.sv
 *     Project     : DTI_PHY
 *     Author      : Thai Nam
 *     Created     : 2016-01-27 09:49:53
 *     Description :
 *
 *     @Last Modified by:   Thai Nam
 *     @Last Modified time: 2016-01-27 15:05:49
 *-----------------------------------------------------------------------------
 */
typedef class dti_sysclk_drv;
typedef class dti_sysclk_seqr;

class dti_sysclk_agent extends uvm_env;
  `uvm_component_utils(dti_sysclk_agent)
  //--------------------------------------------------------------------------------------------
  //  Public Properties
  //--------------------------------------------------------------------------------------------
  dti_sysclk_drv   drv ;
  dti_sysclk_seqr  seqr;

//pragma protect begin_protected
//pragma protect encrypt_agent="NCPROTECT"
//pragma protect encrypt_agent_info="Encrypted using API"
//pragma protect key_keyowner=Cadence Design Systems.
//pragma protect key_keyname=CDS_KEY
//pragma protect key_method=RC5
//pragma protect key_block
SC5QRRR+TXbxBTsj3VZF75gge3jI4acpqejv/WA3zvKY4S7hQKs92kpVg10jAqYz
pW5WL/vEs5AMVGop/vzTk0Oz/3UH9v1/VwQ7iDvvwYxcoQH1BW5Pip2rikIYW7Jh
x7/0gq6w5wcsMEdkqOyf7pbjAyuhSXlI17wZuz8+1i2KOb/up3Gd5Q==
//pragma protect end_key_block
//pragma protect digest_block
UUWAFxMwvLY2/5EJMPj1eznfBzo=
//pragma protect end_digest_block
//pragma protect data_block
Nb+74ab6m+5PAvs20s6+Q5qlvu/HXrxdTRAC9krhUjBgycARXTpstMscFKK7NYlH
4SJyATAkwfYsfknrlPDPVkwltqq5UqMFUXiSd/EZDqBaAnDmavsb8NSWgJE175Ut
qDIYAL8ibOI3P4qkUjRbMq5ACNhFOZBImkSQE2Fy0Te1gz6ajo21t55yG8qnqObu
ny402dcgYNuHpCzYnkj73fX7E19sx1UI4j31k6NbRt5AN9rBQG1YFxlu3o9ny25J
fLHj7lYsiUHnUXtG89lTg0W3gEDo76YlNuUPvaFqz+byDdNxudJGkRtPL2k7SzXo
C649r7W+G3OARQXuEqJiJIyLYrCTAA7KYKoZ0uA4diZxLYohYP/gozN/+EzIN7Th
cnXxy9XZameudROBi+hkC+JNkS8G5fq6JLZncEJB+LxdqEmFhmBgTDExNruNAHHb
gbgG+fmR7UWsQFJSwvwNGf9S65bA7wsiVIJ/Dkk7Q0Z9eyxLM7qjlz01Km1I1Y6z
SWttQm0p7YCCkNG4YG8Wpf+HrXdo7kXdS1vo5y3gOi/eWCp84rgDE6U0PLJYnQoh
/3luAjAylPoVr9QFSzcdF5mjOnF2GSQXgMk9Ns+BDDC+SoXXj9Z04gwY4PtwdfTt
Dv+TxJihPXew0jbuI5uu/DbeoJnsP561ymacUXSvv8G3BeloPzwsJIWapOTp0tF0
WpphipnjkFFbe93pEgVz61qUrSa5EhSuYJoWukkj+4iKZSYY3uX8SHnOL7wuFTT9
E8yjwDzZfpH7RaB+B+qw7nFIB+CB4q4qg9I/CL0EE5AiLKajEu6LqwlKrzhzGRMP
cc4nWATdbbDdQwV6tUMjQX5/N0VUVwpwpcARwyNGnUycjLAYkh4RmBbTcFO/2qwG
l03f8kFUKgFxABHRMXSsC7vlPjXQBBgOm97yh/F89dbxx4gUA7CE3Hwld5qdito+
CVeKBXJ5TKy5fmcZGEFTgxH0HvBI+3UwbOe/DlBUcNySwtVdA1fIxUsyjJXXPYUS
pFmn1UPCTXjwyf4wckLJUPQ/t4kuOMvSlQWrMZr6yr6qYSloxUwNXDyi1ySVzt/0
iDZ8c8dmX3aC6fEmF+q6ujP05xT2VeNvKyC6H3cGewfWxJWPse67qmR0KKLSNpDU
pN20jMr6id9e3ilU+D5pOkKMnvbDXC39XXy+fSA75EVr/Fh96FWJ3X59wN1QZQ0a
1eKaPdnIE7LpMUfX19eHvFVpugcSXUcJIDYpnKz084vc/ugswi1vszNnRDWd2ngW
Z/HOuOjXLqgeussZYSqQOkWp/WIKZvhpcqMfwh/VymW5afBCkSxGNmXzxP+cbWfM
TJ+NZbm+x4/HUvskMhUuKLTu+DcmT6vLyuCibamiLa2fRfVvL9X7DODQ58JET9Z/
+4F0WhBTH7g88mVTLNqHJZu0/kQs0So6wLSZ6ddsca8s/ydP6oxIi5tOpfCt+obz
UInDJe39Eu/JzzRsILcQKR0WPFb7lN7HEOWrUW1pYjr+8QDoOqzgBeL5Z4yfeent
B57faa3SMZvW/a6jKTBJn/5RbjB4jJgjazzBQIDGo4pKuoJRw1coTSkhHx/lFO8B
VBHXrvA6FoK0oA8gJVytUiQ9IuQ/L1weGA2voB24seDuLiP5ogME3eYP9AF4Cpd7
XF8B7C50XOKeYEiw8RKE5w==
//pragma protect end_data_block
//pragma protect digest_block
3b/S1H7ySrr7H89YWBNEoVHcJ1U=
//pragma protect end_digest_block
//pragma protect end_protected
endclass
