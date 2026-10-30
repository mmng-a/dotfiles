export PATH="/usr/local/sbin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"
fpath+=(/opt/homebrew/share/zsh/site-functions)

local export ZSHRCS=$ZDOTDIR/zshrcs

# keybind like emacs
bindkey -e

#export FZF_DEFAULT_COMMAND='bat {} --color=always --style=changes,snip'
export FZF_DEFAULT_OPTS='--height 70% --preview-window right:66% --reverse --color=fg+:2'

setopt auto_cd
setopt noclobber

source $ZDOTDIR/zinit-install.zsh

# Plugins
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
zinit ice wait'!0'; zinit load zsh-users/zsh-syntax-highlighting
zinit ice wait'!0'; zinit load zsh-users/zsh-completions
zinit ice wait'!0'; zinit load zsh-users/zsh-autosuggestions

plugins=(git)

for rc in $ZSHRCS/*; do
	[ $rc = '.DS_Store' ] && continue
	source $rc
done

for file in $HOME/dotfiles/bin/completions/*; do
	[ $file = '.DS_Store' ] && continue
	source $file
done

# Pure
autoload -Uz promptinit
promptinit
PURE_GIT_PULL=0
prompt pure

eval "$(anyenv init -)"

# pnpm
export PNPM_HOME="/Users/masashiaso/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust
