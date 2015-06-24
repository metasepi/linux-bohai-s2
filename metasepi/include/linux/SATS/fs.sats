(*
 * OriginalCode: 89076bc31950eee576ecc06460c23466e2d50939 include/linux/fs.h
 *)
staload "metasepi/include/linux/SATS/types.sats"
%{#
#include "include/linux/CATS/fs.cats"
%}

abst@ype dentry_t  = $extype"struct dentry"
typedef dentry_t_p = cPtr0(dentry_t)
vtypedef super_block_t = $extype_struct"struct super_block" of {
  (* xxx --snip-- *)
  s_root= dentry_t_p
  (* xxx --snip-- *)
}

fun new_decode_dev (dev: uint32_t): dev_t = "mac#"
