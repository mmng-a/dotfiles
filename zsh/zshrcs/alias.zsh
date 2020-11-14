alias ql='qlmanage -p '$@' >& /dev/null'
alias cot='cot -n'
alias tree='tree -N -C'
alias hist-fzf='history 1 | fzf'
# https://github.com/Peltoche/lsd
alias ls='lsd'
alias l='ls -l'
alias la='ls -A'
alias lla='ls -lA'

alias fzfp='fzf --preview "bat {} --color=always --style=changes,snip"'
alias fzcopy='fzf | pbcopy'

alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

