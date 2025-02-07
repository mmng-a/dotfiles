alias ql='qlmanage -p '$@' >& /dev/null'
alias cot='cot -n'
alias tree='tree -N -C'
alias hist-fzf='history -r 1 | fzf'
alias spm='swift package'
alias fzfp='fzf --preview "bat {} --color=always --style=changes,snip"'
alias fzcopy='fzf | pbcopy'

# https://github.com/Peltoche/lsd
alias ls='lsd'
alias l='ls -l'
alias la='ls -A'
alias lla='ls -lA'
alias grep='rg'

alias rm="trash $@"
alias mv='mv -i'
alias cp='cp -i'

alias lesr='less -R'
alias bess="bat -f $@ | lesr"

alias ...=../..
alias ....=../../..
alias .....=../../../..

