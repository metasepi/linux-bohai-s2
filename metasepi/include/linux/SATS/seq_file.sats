(*
 * OriginalCode: 46385326cc1577587ed3e7432c2425cf6d3e4308 include/linux/seq_file.h
 *)
%{#
#include "include/linux/CATS/seq_file.cats"
%}

abst@ype seq_file_t   = $extype"struct seq_file"
typedef  seq_file_t_p = cPtr0(seq_file_t)
