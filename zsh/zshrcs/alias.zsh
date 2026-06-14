alias ql='qlmanage -p '$@' >& /dev/null'
alias tree='tree -N -C'
alias histf='history -r 1 | fzf'
alias spm='swift package'
alias fzfp='fzf --preview "bat {} --color=always --style=changes,snip"'
alias fzcopy='fzf | pbcopy'

# https://github.com/Peltoche/lsd
unalias ls 2>/dev/null
function ls() {
	local use_macos_ls=0
	local stop_options=0

	for arg in "$@"; do
		if (( stop_options )); then
			continue
		fi

		case "$arg" in
			--)
				stop_options=1
				;;
			-[^-]*)
				if [[ "${arg#-}" == *[@OeTG]* ]]; then
					use_macos_ls=1
					break
				fi
				;;
		esac
	done

	if (( use_macos_ls )); then
		command ls "$@"
	else
		lsd "$@"
	fi
}
alias l='ls -l'
alias la='ls -A'
alias lla='ls -lA'

unalias rm 2>/dev/null
function rm() {
	local paths=()
	local stop_options=0

	for arg in "$@"; do
		if (( stop_options )); then
			paths+=("$arg")
			continue
		fi

		case "$arg" in
			--)
				stop_options=1
				;;
			-*)
				;;
			*)
				paths+=("$arg")
				;;
		esac
	done

	if (( ${#paths[@]} == 0 )); then
		print -u2 "rm: no paths given"
		return 64
	fi

	trash "${paths[@]}"
}
alias mv='mv -i'
alias cp='cp -i'
alias cat='bat'

alias lesr='less -R'
alias bess="bat -f $@ | lesr"

alias ...=../..
alias ....=../../..
alias .....=../../../..

alias cot='open -a CotEditor'

