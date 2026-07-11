# Extras

## Theme
Powerlevel10k loaded from `~/powerlevel10k/powerlevel10k.zsh-theme`. Customize with `p10k configure` or edit `~/.p10k.zsh`.

## Shell options
| Option | Effect |
|--------|--------|
| `AUTO_CD` | Type a dir name to cd into it |
| `CORRECT` | Suggest corrections for mistyped commands |
| `EXTENDED_GLOB` | Advanced globbing patterns |
| `INTERACTIVE_COMMENTS` | Allow # comments in interactive shell |
| `NO_BEEP` | Disable error beeps |
| `APPEND_HISTORY` | Append history incrementally |
| `SHARE_HISTORY` | Share history across sessions |
| `PROMPT_SUBST` | Command substitution in prompt |
| `MENU_COMPLETE` | Cycle completions with arrows |

History: 50000 entries, no duplicates, shared between terminals.

## Completion
- Menu selection enabled
- Case-insensitive matching with smart separator detection
- Colored output via LS_COLORS
- Group names in cyan

## Key bindings
| Key | Action |
|-----|--------|
| Up/Down | History substring search |
| Home | Beginning of line |
| End | End of line |
| Delete | Delete char under cursor |
| Ctrl+T | fzf file selection |
| Alt+C | fzf directory jump |
| Ctrl+R | fzf history search |
| Alt+Z | Accept autosuggestion |

## Environment
| Var | Value |
|-----|-------|
| `TERM` | `xterm-256color` |
| `EDITOR` | `vim` |
| `VISUAL` | `vim` |
| `PATH` | npm-global, opencode, ~/.local/bin |

## Structure
Configuration lives under `~/.config/zsh/` (symlinked to BlackNode).
Modules are in `~/.config/zsh/modules/` and loaded by `~/.zshrc`.
