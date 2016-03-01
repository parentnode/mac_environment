export PATH=/opt/local/bin:/opt/local/sbin:$PATH

git_prompt () {
	if ! git rev-parse --git-dir > /dev/null 2>&1; then
	  return 0
	fi

	git_branch=$(git branch 2>/dev/null| sed -n '/^\*/s/^\* //p')

	if git diff --quiet 2>/dev/null >&2; then
		git_color=`tput setaf 2`
	else
		git_color=`tput setaf 1`
	fi

	echo " $git_color($git_branch)"
}

export PS1="\[$(tput bold)\]\[$(tput setaf 5)\]\u@\h \[$(tput setaf 2)\]\W\$(git_prompt)\[$(tput sgr0)\]\[$(tput setaf 4)\] \\$"


