# Plugins

All plugins are loaded from `~/.config/zsh/plugins/`.

| Plugin | Source | Description |
|--------|--------|-------------|
| `zsh-autosuggestions` | [zsh-users/zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Suggests commands from history as you type. Accept with right arrow or Alt+Z. |
| `zsh-autopair` | [hlissner/zsh-autopair](https://github.com/hlissner/zsh-autopair) | Auto-closes quotes, brackets, parentheses. |
| `zsh-syntax-highlighting` | [zsh-users/zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Colors commands as you type (green=valid, red=invalid). |
| `fzf-tab` | [Aloxaf/fzf-tab](https://github.com/Aloxaf/fzf-tab) | Replaces tab completion with fzf fuzzy finder interface. |
| `zsh-you-should-use` | [MichaelAquilina/zsh-you-should-use](https://github.com/MichaelAquilina/zsh-you-should-use) | Reminds you when a command has a shorter alias available. |
| `zsh-fzf-history-search` | [joshskidmore/zsh-fzf-history-search](https://github.com/joshskidmore/zsh-fzf-history-search) | Enhances Ctrl+R with fzf interface. |
| `zsh-history-substring-search` | [zsh-users/zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search) | Search history by typing part of a command + up/down arrows. |
| `zsh-completions` | [zsh-users/zsh-completions](https://github.com/zsh-users/zsh-completions) | Extra completion definitions for git, docker, ssh, etc. |
| `fzf-zsh-plugin` | [urbainvaes/fzf-zsh-plugin](https://github.com/urbainvaes/fzf-zsh-plugin) | fzf widgets for cd, processes, files. |

## fzf (system)
Loaded from `/usr/share/fzf/key-bindings.zsh` and `/usr/share/fzf/completion.zsh`. Provides Ctrl+T (files), Alt+C (cd), and base completion widgets.
