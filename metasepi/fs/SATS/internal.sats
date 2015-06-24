(*
 * OriginalCode: eb6ef3df4faa5424cf2a24b4e4f3eeceb1482a8e fs/internal.h
 *)
staload "metasepi/include/linux/SATS/types.sats"
staload "metasepi/include/linux/SATS/fs.sats"
%{#
#include "fs/CATS/internal.cats"
%}

fun user_get_super (dev: dev_t): [l:addr] (option_v(super_block_t@l, l > null) | ptr(l)) = "mac#"
