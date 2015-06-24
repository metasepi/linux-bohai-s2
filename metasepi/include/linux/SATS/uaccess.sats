(*
 * OriginalCode: 8222dbe21e79338de92d5e1956cd1e3994cc9f93 include/linux/uaccess.h
 *)
%{#
#include "include/linux/CATS/uaccess.cats"
%}

fun copy_to_user (to: ptr, from: ptr, n: ulint): lint = "mac#"
