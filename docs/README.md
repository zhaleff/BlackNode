# BlackNode field manual

BlackNode is a complete desktop for Arch Linux built on Hyprland. This manual covers what is in the repo, how the parts connect, and what needs attention before the desktop works. It assumes you can edit text files and run commands. For Hyprland itself, use the Hyprland wiki.

The project follows Stoicism: control what is yours, remove what is not necessary, and prepare for failure. [philosophy.md](philosophy.md) explains how those rules shape the repository.

When the code and the manual disagree, the code wins. Then fix the manual.

## Start here

| If you want to... | Read |
|---|---|
| Understand the idea behind the project | [philosophy.md](philosophy.md) |
| See what gets linked, generated, and versioned | [anatomy.md](anatomy.md) |
| Install from zero and reach a usable desktop | [firstBoot.md](firstBoot.md) |
| Change colors, typography, or the bar | [aesthetics.md](aesthetics.md) |
| Touch Hyprland, keybinds, rules, or locking | [desktop.md](desktop.md) |
| Use the menu, notifications, shell, and apps | [dailyUse.md](dailyUse.md) |
| Find what is odd, unfinished, or broken | [looseEnds.md](looseEnds.md) |

## Conventions

- `~` is the user's home. The repo is expected at `~/BlackNode`.
- "Generated" means the file is not in git and is produced by `matugen` or a script. If you delete it, `git checkout` will not bring it back.
- Command blocks run from the repo root unless a different path is shown.
- The Waybar group names (`hollow-*`) and the absolute paths are part of the contract. Renaming them breaks selectors or scripts.
