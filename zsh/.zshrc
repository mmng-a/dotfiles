export PATH="/usr/local/sbin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"
export PATH="/opt/homebrew/share/zsh/site-functions:$PATH"

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
fpath+=(/opt/homebrew/share/zsh/site-functions)
autoload -Uz promptinit
promptinit
PURE_GIT_PULL=0
prompt pure

eval "$(gh completion -s zsh)"
eval "$(anyenv init -)"

# pnpm
export PNPM_HOME="/Users/masashiaso/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk
