alias python='python3'
alias pip='pip3'
alias ql='qlmanage -p '$@' >& /dev/null'
alias cot='cot -n'
alias tree='tree -N -C'
alias hist-fzf='history 1 | fzf'
# https://github.com/Peltoche/lsd
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'

alias fzfp='fzf --preview "bat {} --color=always --style=changes,snip"'

alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
