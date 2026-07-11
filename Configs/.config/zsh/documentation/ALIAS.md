# Aliases

## Pacman
| Alias | Command | Description |
|-------|---------|-------------|
| `pac` | `sudo pacman` | Base pacman with sudo |
| `pacupg` | `sudo pacman -Syu` | Full system upgrade |
| `pacin` | `sudo pacman -S` | Install package |
| `pacrem` | `sudo pacman -Rns` | Remove package and deps |
| `search` | `pacman -Ss` | Search packages |
| `cleanup` | `sudo pacman -Rns $(pacman -Qtdq); sudo pacman -Sc` | Remove orphans and clean cache |
| `yayupdate` | `yay -Syu` | Update AUR packages |

## File System
| Alias | Command | Description |
|-------|---------|-------------|
| `ls` | `exa --icons --color=always --group-directories-first` | List with icons, dirs first |
| `la` | `exa -a --icons --color=always` | List all (incl hidden) |
| `ll` | `exa -l --icons --color=always --git` | Long listing with git status |
| `lla` | `exa -la --icons --color=always` | Long listing + hidden |
| `tree` | `exa --tree --icons --color=always --level=3` | Tree view 3 levels |
| `mkd` | `mkdir -pv` | Create dirs recursively |
| `t` | `touch` | Create empty file |
| `cp` | `cp -iv` | Copy with confirm + verbose |
| `mv` | `mv -iv` | Move with confirm + verbose |
| `rm` | `rm -iv` | Remove with confirm + verbose |
| `shred` | `shred -u -z -n 5` | Secure delete (overwrite + remove) |
| `df` | `df -hT` | Disk usage human readable |
| `du` | `du -h --max-depth=1` | Directory sizes current level |
| `..` | `cd ..` | Up one dir |
| `...` | `cd ../..` | Up two dirs |
| `bat` | `bat --style=full` | Cat with syntax highlighting |

## System
| Alias | Command | Description |
|-------|---------|-------------|
| `cl` | `clear` | Clear terminal |
| `ff` | `fastfetch` | System info |
| `clock` | `peaclock` | Terminal clock |
| `wf` | `wf-recorder` | Screen recording (Wayland) |
| `win` | `hyprctl clients` | List Hyprland windows |
| `reboot` | `sudo reboot` | Reboot |
| `shutdown` | `sudo shutdown now` | Shutdown |
| `grep` | `grep --color=auto -n` | Grep with color + line numbers |
| `tailf` | `tail -f` | Follow log file |
| `ports` | `ss -tulanp` | Listening ports |
| `firefox` | `systemd-run ... firefox` | Firefox with memory limits |

## Editors
| Alias | Command |
|-------|---------|
| `nn` | `nano` |
| `vi` | `vim` |
| `view` | `vim -R` |
| `code` | `code` |

## Git
| Alias | Command |
|-------|---------|
| `gs` | `git status` |
| `ga` | `git add` |
| `gc` | `git commit -m` |
| `gac` | `git add . && git commit -m` |
| `gp` | `git push` |
| `gl` | `git pull` |
| `gd` | `git diff` |
| `gb` | `git branch` |
| `gco` | `git checkout` |
| `glog` | `git log --oneline --graph --decorate` |
| `gcl` | `git clone` |
| `gstash` | `git stash` |

## Docker
| Alias | Command |
|-------|---------|
| `dps` | `docker ps` |
| `dim` | `docker images` |
| `dcu` | `docker compose up -d` |
| `dcd` | `docker compose down` |
| `dcl` | `docker compose logs -f` |

## Dev
| Alias | Command | Description |
|-------|---------|-------------|
| `py` | `python3` | Python 3 |
| `pip` | `pip3` | Pip for Python 3 |
| `venv` | `python3 -m venv .venv && source .venv/bin/activate` | Create + activate venv |
| `fd` | `firebase deploy` | Deploy to Firebase |
| `yt` | `yt-dlp` | Download videos |
| `weather` | `curl wttr.in/~Madrid` | Madrid weather |
| `matrix` | `cmatrix -b` | Matrix rain |
| `norvek` | `./gradlew assembleDebug && adb install ...` | Build + deploy Android APK |
| `pdev` | `pnpm run dev` | Dev server |
| `pbuild` | `pnpm run build` | Build project |
| `pinstall` | `pnpm add` | Install package |
