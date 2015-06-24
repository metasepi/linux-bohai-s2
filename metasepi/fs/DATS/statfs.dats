(*
 * OriginalCode: 9d05746e7b16d8565dddbe3200faa1e669d23bbf fs/statfs.c
 *)
#define ATS_DYNLOADFLAG 0
#include "share/atspre_define.hats"
#include "metasepi/staloadall.hats"
staload "metasepi/include/linux/SATS/errno.sats"
staload "metasepi/include/linux/SATS/types.sats"
staload "metasepi/include/linux/SATS/syscalls.sats"
staload "metasepi/include/linux/SATS/export.sats"
staload "metasepi/include/linux/SATS/fs.sats"
staload "metasepi/include/linux/SATS/file.sats"
staload "metasepi/include/linux/SATS/mount.sats"
staload "metasepi/include/linux/SATS/namei.sats"
staload "metasepi/include/linux/SATS/statfs.sats"
staload "metasepi/include/linux/SATS/security.sats"
staload "metasepi/include/linux/SATS/uaccess.sats"
staload "metasepi/fs/SATS/internal.sats"
staload UN = "prelude/SATS/unsafe.sats"

extern fun memset (s:ptr, c:int, n:size_t): ptr = "mac#" // xxx UNSAFE

extern fun statfs_by_dentry_wrap
(dentry: dentry_t_p, sbuf: &kstatfs_t? >> opt (kstatfs_t, i==0)): #[i:int | i <= 0] int(i) = "mac#"

extern fun vfs_ustat_ats
(dev: dev_t, sbuf: &kstatfs_t? >> opt (kstatfs_t, i==0)): #[i:int | i <= 0] int(i) = "mac#"
implement vfs_ustat_ats(dev, sbuf) = let
  val (pfopt | p) = user_get_super(dev)
in
  if (p > 0) then let
      prval Some_v (pf) = pfopt
      val e = statfs_by_dentry_wrap(p->s_root, sbuf);
      val () = drop_super(pf | p)
    in
      e
    end else let
      prval None_v () = pfopt
      prval () = opt_none{kstatfs_t}(sbuf)
    in
      (~ EINVAL)
    end
end

extern fun syscall_ustat_ats (dev: dev_t, ubuf: ptr): int = "sta#"
implement syscall_ustat_ats (dev, ubuf) = r where {
  fun copy_tmp (sbuf: &kstatfs_t): int = r where {
    var tmp: ustat_t
    val _ = memset(addr@tmp, 0, sizeof<ustat_t>)
    val () = tmp.f_tfree := $UN.cast(sbuf.f_bfree)
    val () = tmp.f_tinode := $UN.cast(sbuf.f_ffree)
    val r = if copy_to_user(ubuf, addr@tmp, $UN.cast sizeof<ustat_t>) != 0
            then (~ EFAULT) else 0
  }
  var sbuf: kstatfs_t?
  val e = vfs_ustat_ats(new_decode_dev(dev), sbuf)
  val r = if e != 0 then let
      prval () = opt_unnone(sbuf)
    in
      e
    end else let
      prval () = opt_unsome(sbuf)
    in
      copy_tmp(sbuf)
    end
}

%{$
static int flags_by_mnt(int mnt_flags)
{
	int flags = 0;

	if (mnt_flags & MNT_READONLY)
		flags |= ST_RDONLY;
	if (mnt_flags & MNT_NOSUID)
		flags |= ST_NOSUID;
	if (mnt_flags & MNT_NODEV)
		flags |= ST_NODEV;
	if (mnt_flags & MNT_NOEXEC)
		flags |= ST_NOEXEC;
	if (mnt_flags & MNT_NOATIME)
		flags |= ST_NOATIME;
	if (mnt_flags & MNT_NODIRATIME)
		flags |= ST_NODIRATIME;
	if (mnt_flags & MNT_RELATIME)
		flags |= ST_RELATIME;
	return flags;
}

static int flags_by_sb(int s_flags)
{
	int flags = 0;
	if (s_flags & MS_SYNCHRONOUS)
		flags |= ST_SYNCHRONOUS;
	if (s_flags & MS_MANDLOCK)
		flags |= ST_MANDLOCK;
	return flags;
}

static int calculate_f_flags(struct vfsmount *mnt)
{
	return ST_VALID | flags_by_mnt(mnt->mnt_flags) |
		flags_by_sb(mnt->mnt_sb->s_flags);
}

static int statfs_by_dentry(struct dentry *dentry, struct kstatfs *buf)
{
	int retval;

	if (!dentry->d_sb->s_op->statfs)
		return -ENOSYS;

	memset(buf, 0, sizeof(*buf));
	retval = security_sb_statfs(dentry);
	if (retval)
		return retval;
	retval = dentry->d_sb->s_op->statfs(dentry, buf);
	if (retval == 0 && buf->f_frsize == 0)
		buf->f_frsize = buf->f_bsize;
	return retval;
}

int vfs_statfs(struct path *path, struct kstatfs *buf)
{
	int error;

	error = statfs_by_dentry(path->dentry, buf);
	if (!error)
		buf->f_flags = calculate_f_flags(path->mnt);
	return error;
}
EXPORT_SYMBOL(vfs_statfs);

int user_statfs(const char __user *pathname, struct kstatfs *st)
{
	struct path path;
	int error;
	unsigned int lookup_flags = LOOKUP_FOLLOW|LOOKUP_AUTOMOUNT;
retry:
	error = user_path_at(AT_FDCWD, pathname, lookup_flags, &path);
	if (!error) {
		error = vfs_statfs(&path, st);
		path_put(&path);
		if (retry_estale(error, lookup_flags)) {
			lookup_flags |= LOOKUP_REVAL;
			goto retry;
		}
	}
	return error;
}

int fd_statfs(int fd, struct kstatfs *st)
{
	struct fd f = fdget_raw(fd);
	int error = -EBADF;
	if (f.file) {
		error = vfs_statfs(&f.file->f_path, st);
		fdput(f);
	}
	return error;
}

static int do_statfs_native(struct kstatfs *st, struct statfs __user *p)
{
	struct statfs buf;

	if (sizeof(buf) == sizeof(*st))
		memcpy(&buf, st, sizeof(*st));
	else {
		if (sizeof buf.f_blocks == 4) {
			if ((st->f_blocks | st->f_bfree | st->f_bavail |
			     st->f_bsize | st->f_frsize) &
			    0xffffffff00000000ULL)
				return -EOVERFLOW;
			/*
			 * f_files and f_ffree may be -1; it's okay to stuff
			 * that into 32 bits
			 */
			if (st->f_files != -1 &&
			    (st->f_files & 0xffffffff00000000ULL))
				return -EOVERFLOW;
			if (st->f_ffree != -1 &&
			    (st->f_ffree & 0xffffffff00000000ULL))
				return -EOVERFLOW;
		}

		buf.f_type = st->f_type;
		buf.f_bsize = st->f_bsize;
		buf.f_blocks = st->f_blocks;
		buf.f_bfree = st->f_bfree;
		buf.f_bavail = st->f_bavail;
		buf.f_files = st->f_files;
		buf.f_ffree = st->f_ffree;
		buf.f_fsid = st->f_fsid;
		buf.f_namelen = st->f_namelen;
		buf.f_frsize = st->f_frsize;
		buf.f_flags = st->f_flags;
		memset(buf.f_spare, 0, sizeof(buf.f_spare));
	}
	if (copy_to_user(p, &buf, sizeof(buf)))
		return -EFAULT;
	return 0;
}

static int do_statfs64(struct kstatfs *st, struct statfs64 __user *p)
{
	struct statfs64 buf;
	if (sizeof(buf) == sizeof(*st))
		memcpy(&buf, st, sizeof(*st));
	else {
		buf.f_type = st->f_type;
		buf.f_bsize = st->f_bsize;
		buf.f_blocks = st->f_blocks;
		buf.f_bfree = st->f_bfree;
		buf.f_bavail = st->f_bavail;
		buf.f_files = st->f_files;
		buf.f_ffree = st->f_ffree;
		buf.f_fsid = st->f_fsid;
		buf.f_namelen = st->f_namelen;
		buf.f_frsize = st->f_frsize;
		buf.f_flags = st->f_flags;
		memset(buf.f_spare, 0, sizeof(buf.f_spare));
	}
	if (copy_to_user(p, &buf, sizeof(buf)))
		return -EFAULT;
	return 0;
}

SYSCALL_DEFINE2(statfs, const char __user *, pathname, struct statfs __user *, buf)
{
	struct kstatfs st;
	int error = user_statfs(pathname, &st);
	if (!error)
		error = do_statfs_native(&st, buf);
	return error;
}

SYSCALL_DEFINE3(statfs64, const char __user *, pathname, size_t, sz, struct statfs64 __user *, buf)
{
	struct kstatfs st;
	int error;
	if (sz != sizeof(*buf))
		return -EINVAL;
	error = user_statfs(pathname, &st);
	if (!error)
		error = do_statfs64(&st, buf);
	return error;
}

SYSCALL_DEFINE2(fstatfs, unsigned int, fd, struct statfs __user *, buf)
{
	struct kstatfs st;
	int error = fd_statfs(fd, &st);
	if (!error)
		error = do_statfs_native(&st, buf);
	return error;
}

SYSCALL_DEFINE3(fstatfs64, unsigned int, fd, size_t, sz, struct statfs64 __user *, buf)
{
	struct kstatfs st;
	int error;

	if (sz != sizeof(*buf))
		return -EINVAL;

	error = fd_statfs(fd, &st);
	if (!error)
		error = do_statfs64(&st, buf);
	return error;
}

int statfs_by_dentry_wrap(void *dentry, struct kstatfs *buf)
{
	return statfs_by_dentry((struct dentry *) dentry, buf);
}

int vfs_ustat(dev_t dev, struct kstatfs *sbuf)
{
	return vfs_ustat_ats(dev, sbuf);
}

SYSCALL_DEFINE2(ustat, unsigned, dev, struct ustat __user *, ubuf)
{
	return syscall_ustat_ats(dev, ubuf);
}
%}
