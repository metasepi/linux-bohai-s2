#!/bin/awk -f
# Usage: awk -f metasepi/tools/chkupdate.awk < metasepi/fs/proc/DATS/version.dat

BEGIN {
	line = 0
	original = ""
	git_commit = ""
}

// {
	line++
}

/Original: / {
	if (line == 2) {
		original = $3
	}
}

/GitCommit: / {
	if (line == 3) {
		git_commit = $3
	}
}

END {
	if (original != "" && git_commit != "") {
		printf "git diff -r %s %s", git_commit, original
	}
}
