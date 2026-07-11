# Pacman
alias pac='sudo pacman'
alias pacupg='sudo pacman -Syu'
alias pacin='sudo pacman -S'
alias pacrem='sudo pacman -Rns'
alias search='pacman -Ss'
alias cleanup='sudo pacman -Rns $(pacman -Qtdq); sudo pacman -Sc'
alias yayupdate='yay -Syu'

# File System
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

# System
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
alias firefox='systemd-run --unit=my-firefox --user --scope \
  -p MemoryHigh=1500M \
  -p MemoryMax=2G \
  -p MemorySwapMax=500M \
  firefox'

# Editors
alias nn='nano'
alias vi='vim'
alias view='vim -R'
alias code='code'

# Git
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gac='git add . && git commit -m'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'
alias glog='git log --oneline --graph --decorate'
alias gcl='git clone'
alias gstash='git stash'

# Docker
alias dps='docker ps'
alias dim='docker images'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'

# Dev
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv .venv && source .venv/bin/activate'
alias fd='firebase deploy'
alias yt='yt-dlp'
alias weather='curl wttr.in/~Madrid'
alias matrix='cmatrix -b'
alias norvek='./gradlew assembleDebug && adb install app/build/outputs/apk/debug/app-debug.apk'
alias pdev="pnpm run dev"
alias pbuild="pnpm run build"
alias pinstall="pnpm add"
