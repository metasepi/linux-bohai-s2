(*
 * Original:  fs/internal.h
 * GitCommit: 50652963eae6afe13678dc84d789a174306a4df7
 *)
staload "metasepi/include/linux/SATS/types.sats"
staload "metasepi/include/linux/SATS/fs.sats"
%{#
#include "fs/CATS/internal.cats"
%}

fun user_get_super (dev: dev_t): super_block_t_p = "mac#"
fun drop_super (sb: super_block_t_p) :void = "mac#"
