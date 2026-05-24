# git-fshow, git-fbr, git-fcheckout
# are in /usr/local/bin

# change directory by fuzzy searching latest visited
alias cdf='fzf-cdr'
function fzf-cdr() {
	target_dir=`cdr -l | sed 's/^[^ ]* *//' | fzf | sed -e "s@~@$HOME@"`
	target_dir=`echo $target_dir | sed -e 's/\\\//'`
	if [ -n "$target_dir" ]; then
		cd $target_dir
	fi
}

# Create a directory and change directory to it
alias mcd='mkdir-cd'
function mkdir-cd() {
	mkdir $@
	cd $@
}

