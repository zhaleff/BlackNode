# ═══════════════════════════════════════
#  HOLLOWSEC ZSH CONFIG
# ═══════════════════════════════════════

## Instant Prompt
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

## Theme
# source ~/powerlevel10k/powerlevel10k.zsh-theme
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

setopt PROMPT_SUBST

parse_git() {
  git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/%F{13} \1%f/'
}

PROMPT='%F{14}%~ $(parse_git)%F{12}❯ %f'

zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
export LS_COLORS="di=1;34:ex=31:ln=35:su=30;41:tw=30;42:ow=30;43"

## Plugins
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/plugins/zsh-autopair/autopair.zsh
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/plugins/fzf-tab/fzf-tab.plugin.zsh
source ~/.zsh/plugins/zsh-you-should-use/you-should-use.plugin.zsh
source ~/.zsh/plugins/zsh-fzf-history-search/zsh-fzf-history-search.plugin.zsh
source ~/.zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source ~/.zsh/plugins/zsh-completions/zsh-completions.plugin.zsh
source ~/.zsh/plugins/fzf-zsh-plugin/fzf-zsh-plugin.plugin.zsh

## FZF system bindings
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

## Key Bindings
bindkey -e
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^T' fzf-file-widget
bindkey '^[^C' fzf-cd-widget
bindkey '^R' fzf-history-widget
bindkey '^[z' autosuggest-accept

## Shell Options
setopt AUTO_CD
setopt CORRECT
setopt EXTENDED_GLOB
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt PROMPT_SUBST
setopt MENU_COMPLETE

## History
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY

## Completion
autoload -Uz compinit
compinit
zmodload zsh/complist
fpath=(~/.zsh/plugins/zsh-completions/src $fpath)

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{cyan}-- %d --%f'

## Environment
export TERM=xterm-256color
export PATH="$HOME/.npm-global/bin:$PATH"
export EDITOR=vim
export VISUAL=vim
[ -f ~/.dircolors ] && eval "$(dircolors ~/.dircolors)"

## Aliases - Pacman
alias pac='sudo pacman'
alias pacupg='sudo pacman -Syu'
alias pacin='sudo pacman -S'
alias pacrem='sudo pacman -Rns'
alias search='pacman -Ss'
alias cleanup='sudo pacman -Rns $(pacman -Qtdq); sudo pacman -Sc'
alias yayupdate='yay -Syu'

## Aliases - File System
alias ls='exa --icons --color=always --group-directories-first'
alias la='exa -a --icons --color=always'
alias ll='exa -l --icons --color=always --git'
alias lla='exa -la --icons --color=always'
alias tree='exa --tree --icons --color=always --level=3'
alias mkd='mkdir -pv'
alias t='touch'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias shred='shred -u -z -n 5'
alias df='df -hT'
alias du='du -h --max-depth=1'
alias ..='cd ..'
alias ...='cd ../..'
alias bat='bat --style=full'
alias norvek='./gradlew assembleDebug && adb install app/build/outputs/apk/debug/app-debug.apk'
## Aliases - System
alias cl='clear'
alias ff='fastfetch'
alias clock='peaclock'
alias wf='wf-recorder'
alias win='hyprctl clients'
alias reboot='sudo reboot'
alias shutdown='sudo shutdown now'
alias grep='grep --color=auto -n'
alias tailf='tail -f'
alias ports='ss -tulanp'

## Aliases - Editors
alias nn='nano'
alias vi='vim'
alias view='vim -R'
alias code='code'

## Aliases - Git
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'
alias glog='git log --oneline --graph --decorate'
alias gcl='git clone'
alias gstash='git stash'

## Aliases - Docker
alias dps='docker ps'
alias dim='docker images'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'

## Aliases - Dev
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv .venv && source .venv/bin/activate'
alias fd='firebase deploy'
alias yt='yt-dlp'
alias weather='curl wttr.in/~Madrid'
alias matrix='cmatrix -b'

## Extract function
extract() {
  if [ -f "$1" ]; then
    case $1 in
      *.tar.bz2) tar xjf $1 ;;
      *.tar.gz)  tar xzf $1 ;;
      *.bz2)     bunzip2 $1 ;;
      *.rar)     unrar x $1 ;;
      *.gz)      gunzip $1 ;;
      *.tar)     tar xf $1 ;;
      *.tbz2)    tar xjf $1 ;;
      *.tgz)     tar xzf $1 ;;
      *.zip)     unzip $1 ;;
      *.Z)       uncompress $1 ;;
      *.7z)      7z x $1 ;;
      *)         echo "'$1' cannot be extracted" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}
