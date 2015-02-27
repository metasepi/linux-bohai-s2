(*
 * Original:  include/linux/uaccess.h
 * GitCommit: 62b94a08da1bae9d187d49dfcd6665af393750f8
 *)
%{#
#include "include/linux/CATS/uaccess.cats"
%}

fun copy_to_user (to: ptr, from: ptr, n: ulint): lint = "mac#"
