fpath=(~/.zsh/completion $fpath)
autoload -Uz compinit
compinit

# 補完の選択が楽に
zstyle ':completion:*' menu select
# 補完候補に色つける
autoload -U colors ; colors ; zstyle ':completion:*' list-colors "${LS_COLORS}"
# 補完の色
export LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
# キャッシュの利用による補完の高速化
zstyle ':completion::complete:*' use-cache true
# 大文字・小文字を区別しない(大文字を入力した場合は区別する)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# --prefix=/usr などの = 以降でも補完
setopt magic_equal_subst
setopt complete_in_word

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8,bold"
ZSH_AUTOSUGGEST_HISTORY_IGNORE=("cd *" "?(#c50,)")
ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion)

