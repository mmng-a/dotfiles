export ZSHRCS=$ZDOTDIR/zshrcs

# keybind like emacs
bindkey -e

# Starship
export STARSHIP_CONFIG=~/.config/starship.toml
eval "$(starship init zsh)"

eval "$(gh completion -s zsh)"

#export FZF_DEFAULT_COMMAND='bat {} --color=always --style=changes,snip'
export FZF_DEFAULT_OPTS='--height 70% --preview-window right:66% --reverse --color=fg+:2'

setopt auto_cd
setopt noclobber

source $ZDOTDIR/zinit-install.zsh

# Plugins
source "${HOME}/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
zinit load momo-lab/zsh-abbrev-alias
zinit ice wait'!0'; zinit load zsh-users/zsh-syntax-highlighting
zinit ice wait'!0'; zinit load zsh-users/zsh-completions
zinit load zsh-users/zsh-autosuggestions

plugins=(git)

for rc in $ZSHRCS/*; do
	[ $rc = '.' ] && continue
	[ $rc = '.DS_Store' ] && continue
	source $rc
done

export PATH=$PATH:$HOME/dotfiles/bin/

for file in $HOME/dotfiles/bin/completions/*; do
	[ $file = '.' ] && continue
	[ $file = '.DS_Store' ] && continue
	source $file
done
