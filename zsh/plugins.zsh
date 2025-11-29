# ===================================
# プラグイン固有の設定
# ===================================

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ZSH_AUTOSUGGEST_MANUAL_REBIND を設定することで、
# zsh-syntax-highlightingなどのプラグインによる上書きを防ぎ、
# autosuggestionsがキーバインドを再設定できるようにする。
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# zsh-autosuggestionsで、Tabキーでサジェストを受け入れる設定
bindkey '^I' autosuggest-accept
