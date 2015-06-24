(*
 * OriginalCode: 365b18189789bfa1acd9939e6312b8a4b4577b28 include/linux/statfs.h
 *)
staload "metasepi/include/linux/SATS/types.sats"
staload "metasepi/include/linux/SATS/fs.sats"
%{#
#include "include/linux/CATS/statfs.cats"
%}

typedef kstatfs_t = $extype_struct"struct kstatfs" of {
  f_type=    lint,
  f_bsize=   lint,
  f_blocks=  uint64_t,
  f_bfree=   uint64_t,
  f_bavail=  uint64_t,
  f_files=   uint64_t,
  f_ffree=   uint64_t,
  f_fsid=    kernel_fsid_t,
  f_namelen= lint,
  f_frsize=  lint,
  f_flags=   lint,
  f_spare=   @[lint][4]
}

fun drop_super{l:addr} (super_block_t@l | sb: ptr(l)) :void = "mac#"
