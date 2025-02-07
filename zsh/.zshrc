export PATH="/usr/local/sbin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"
export PATH="/opt/homebrew/share/zsh/site-functions:$PATH"

local export ZSHRCS=$ZDOTDIR/zshrcs

# keybind like emacs
bindkey -e

# Starship
export STARSHIP_CONFIG=~/.config/starship.toml
eval "$(starship init zsh)"

eval "$(gh completion -s zsh)"
eval "$(anyenv init -)"

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

# ??
plugins=(git)

for rc in $ZSHRCS/*; do
	[ $rc = '.DS_Store' ] && continue
	source $rc
done

for file in $HOME/dotfiles/bin/completions/*; do
	[ $file = '.DS_Store' ] && continue
	source $file
done


# pnpm
export PNPM_HOME="/Users/masashiaso/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
