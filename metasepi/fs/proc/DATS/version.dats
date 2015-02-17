(*
 * Original:   fs/proc/version.c
 * Git commit: abaf3787ac26ba33e2f75e76b1174c32254c25b0
 *)
#define ATS_DYNLOADFLAG 0
#include "share/atspre_define.hats"
#include "metasepi/staloadall.hats"
staload "metasepi/include/linux/SATS/fs.sats"
staload "metasepi/include/linux/SATS/init.sats"
staload "metasepi/include/linux/SATS/kernel.sats"
staload "metasepi/include/linux/SATS/proc_fs.sats"
staload "metasepi/include/linux/SATS/seq_file.sats"
staload "metasepi/include/linux/SATS/utsname.sats"

%{
static int version_proc_show(struct seq_file *m, void *v)
{
	seq_printf(m, linux_proc_banner,
		utsname()->sysname,
		utsname()->release,
		utsname()->version);
	return 0;
}

static int version_proc_open(struct inode *inode, struct file *file)
{
	return single_open(file, version_proc_show, NULL);
}

static const struct file_operations version_proc_fops = {
	.open		= version_proc_open,
	.read		= seq_read,
	.llseek		= seq_lseek,
	.release	= single_release,
};

static int __init proc_version_init(void)
{
	proc_create("version", 0, NULL, &version_proc_fops);
	return 0;
}
fs_initcall(proc_version_init);
%}
