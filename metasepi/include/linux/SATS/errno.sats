(*
 * Original:  include/linux/errno.h
 * GitCommit: 41003a7bcfed1255032e1e7c7b487e505b22e298
 *)
%{#
#include "include/linux/CATS/errno.cats"
%}

#define EFAULT 14 (* Bad address *)
#define EINVAL 22 (* Invalid argument *)
