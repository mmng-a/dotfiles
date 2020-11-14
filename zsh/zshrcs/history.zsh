export HISTFILE=$ZDOTDIR/.zsh_history
export HISTSIZE=1000
export SAVENIST=100000
setopt EXTENDED_HISTORY
setopt hist_ignore_dups
setopt hist_no_store
setopt inc_append_history
setopt share_history
bindkey '^P' history-beginning-search-backward

# cdr
autoload -Uz is-at-least
if is-at-least 4.3.11; then
  autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
  add-zsh-hook chpwd chpwd_recent_dirs
  zstyle ':chpwd:*' recent-dirs-max 1000
  zstyle ':chpwd:*' recent-dirs-default true
  zstyle ':completion:*' recent-dirs-insert both
fi
