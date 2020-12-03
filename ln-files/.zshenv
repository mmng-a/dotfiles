zmodload zsh/zprof && zprof

export DOTFILES=$HOME/dotfiles
export ZDOTDIR=$DOTFILES/zsh
export LESSHISTFILE=$DOTFILES/lesshst

export EDITOR=vim

export PATH=$HOME/.cargo/bin:$PATH
export PATH=$DOTFILES/bin/:$PATH
export PATH=/usr/local/opt/llvm/bin:$PATH

export LC_ALL=ja_JP.UTF-8
export LANG=ja_JP.UTF-8

alias brew='PATH=/usr/local/sbin/:/usr/local/bin/:/usr/bin/:/bin/:/usr/sbin/:/sbin/ brew'
