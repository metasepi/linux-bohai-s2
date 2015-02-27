#include <sys/types.h>
#include <stdio.h>
#include <ustat.h>

/* /dev/sda1 */
#define MAJOR 8
#define MINOR 1

int main() {
	dev_t d = (MAJOR << 8) + MINOR;
	struct ustat ubuf;
	int r;

	r = ustat(d, &ubuf);
	if (0 == r) {
		printf("Total free blocks: %d\n", ubuf.f_tfree);
		printf("Number of free inodes: %d\n", ubuf.f_tinode);
		printf("Filsys name: %s\n", ubuf.f_fname);
		printf("Filsys pack name: %s\n", ubuf.f_fpack);
	} else {
		printf("*** ustat(2) return %d\n", r);
	}

	return r;
}
