#!/bin/awk -f
# Usage: awk -f metasepi/tools/chkupdate.awk  metasepi/fs/proc/DATS/version.dat

BEGIN {
	comment_level = 0
}

/^\(\*/ {
	comment_level++
}

/^ \*\)/ {
	comment_level++
}

/^ \* OriginalCode: / {
	if (comment_level == 1) {
		git_commit = $3
		filename = $4
		printf("### %s\n", FILENAME)
		command = sprintf("git diff -r %s %s | cat", git_commit, filename)
		system(command)
	}
}
