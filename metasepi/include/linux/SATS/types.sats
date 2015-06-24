(*
 * OriginalCode: 23f40a94d860449f39f00c3350bf850d15983e63 include/linux/types.h
 *)
%{#
#include "include/linux/CATS/types.cats"
%}

typedef uint32_t       = uint
typedef uint64_t       = ullint
typedef kernel_dev_t   = uint32_t
typedef kernel_daddr_t = int
typedef kernel_ino_t   = ulint
typedef kernel_fsid_t  = $extype_struct"struct{ int val[2] }" of { value= @[int][2] }
typedef dev_t          = kernel_dev_t
typedef ustat_t = $extype_struct"struct ustat" of {
  f_tfree=  kernel_daddr_t,
  f_tinode= kernel_ino_t,
  f_fname=  @[char][6],
  f_fpack=  @[char][6]
}
