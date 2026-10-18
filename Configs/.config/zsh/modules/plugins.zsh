_plug() {
  [[ -r $1 ]] && source "$1" || print -u2 "zsh: plugin no encontrado: $1"
}

HISTFILE=${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history
HISTSIZE=10000
SAVEHIST=10000
mkdir -p "${HISTFILE:h}"
setopt HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS \
       SHARE_HISTORY EXTENDED_HISTORY

autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"

zstyle ':completion:*' menu no
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:*' switch-group '<' '>'

export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border=sharp --info=inline'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :200 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {}'"
source <(fzf --zsh)

_plug /usr/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=40
_plug /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^ ' autosuggest-accept

_plug /usr/share/zsh/plugins/zsh-autopair/autopair.zsh

YSU_MESSAGE_POSITION="after"
_plug /usr/share/zsh/plugins/zsh-you-should-use/you-should-use.plugin.zsh

_plug /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
_plug /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

bindkey "${terminfo[kcuu1]}" history-substring-search-up
bindkey "${terminfo[kcud1]}" history-substring-search-down
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down
