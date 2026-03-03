<h1 align="center">HollowSec's ZSH Configuration: Extras</h1>

<div align="center">
  <p>
    <a href="#"><img src="https://img.shields.io/badge/shell-ZSH-brightgreen?style=for-the-badge&logo=gnu-bash&logoColor=white&labelColor=302D41&color=CBA6F7" alt="Shell"></a>&nbsp;&nbsp;
    <a href="#"><img src="https://img.shields.io/badge/prompt-Powerlevel10k-blue?style=for-the-badge&logo=powerShell&logoColor=white&labelColor=302D41&color=89B4FA" alt="Prompt"></a>&nbsp;&nbsp;
    <a href="#"><img src="https://img.shields.io/badge/fzf-enabled-ff69b4?style=for-the-badge&logo=fileZilla&logoColor=white&labelColor=302D41&color=F9E2AF" alt="fzf"></a>
  </p>
</div>

Beyond the rich collection of plugins and thoughtfully crafted aliases, this ZSH configuration includes a set of core enhancements that elevate the everyday terminal experience.  Here’s a quick look at the foundation.

---

## Prompt: Powerlevel10k

The prompt is provided by **Powerlevel10k**, a fast and flexible theme.  It displays:

- Current directory (truncated intelligently)
- Git branch and status (clean/modified/staged)
- Exit code of the last command (if non‑zero)
- Command execution time
- User and hostname (when needed)

Configuration is stored in `~/.p10k.zsh` – you can run `p10k configure` to tweak it interactively.

---

## Key Bindings

A selection of custom bindings makes navigation and history searching a breeze:

| Keys          | Action                              |
|---------------|-------------------------------------|
| `↑` / `↓`     | History substring search (up/down)  |
| `Home` / `End`| Beginning / end of line             |
| `Delete`      | Delete character under cursor       |
| `Ctrl+T`      | fzf file selection (paste path)     |
| `Alt+^C`      | fzf directory jump                  |
| `Ctrl+R`      | fzf history search                   |
| `Alt+Z`       | Accept autosuggestion               |

These are defined after loading the respective plugins, ensuring no conflicts.

---

## Shell Options

Several ZSH options are set to improve usability:

| Option                | Effect                                      |
|-----------------------|---------------------------------------------|
| `AUTO_CD`             | Type a directory name to `cd` into it       |
| `CORRECT`             | Suggest corrections for mistyped commands   |
| `EXTENDED_GLOB`       | Enable advanced globbing patterns           |
| `INTERACTIVE_COMMENTS`| Allow `#` comments in interactive shell     |
| `NO_BEEP`             | Disable beep on errors                      |
| `APPEND_HISTORY`      | Append history incrementally                |
| `SHARE_HISTORY`       | Share history across sessions               |
| `PROMPT_SUBST`        | Allow command substitution in prompt        |
| `MENU_COMPLETE`       | Cycle completions with arrow keys           |

History size is set to 50,000 entries, with duplicate lines ignored.

---

## Completion System

The completion system (`compinit`) is loaded with the following styles:

- Menu selection enabled.
- Case‑insensitive matching with smart detection of hyphens and underscores.
- Coloured output based on `LS_COLORS`.
- Group names displayed in cyan for clarity.

The `fpath` includes `~/.zsh/plugins/zsh-completions/src` for extra completion definitions.

---

## Environment Variables

| Variable | Value                     | Purpose                        |
|----------|---------------------------|--------------------------------|
| `TERM`   | `xterm-256color`          | Enable 256‑colour support      |
| `EDITOR` | `vim`                     | Default editor                 |
| `VISUAL` | `vim`                     | Default visual editor          |
| `PATH`   | Includes `~/.npm-global/bin` | Global npm packages          |

If `~/.dircolors` exists, it is sourced to customise `LS_COLORS`.

---

## Final Thoughts

These settings form the backbone of a terminal environment that is both powerful and a pleasure to use.  Together with the plugins and aliases documented separately, they create a cohesive experience that respects your time and your fingers.

Feel free to adapt any part to your own needs—the shell is yours.

**— HollowSec**
