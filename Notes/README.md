<h1 align="center">BlackNode · Notes</h1>

<div align="center">
  <p>
    <a href="#"><img src="https://img.shields.io/badge/type-simple%20notes-89B4FA?style=for-the-badge&logo=markdown&logoColor=white&labelColor=302D41" alt="Type"></a>&nbsp;&nbsp;
    <a href="#"><img src="https://img.shields.io/badge/editor-neovim-A6E3A1?style=for-the-badge&logo=neovim&logoColor=white&labelColor=302D41" alt="Editor"></a>&nbsp;&nbsp;
    <a href="#"><img src="https://img.shields.io/badge/launcher-rofi-F9E2AF?style=for-the-badge&logo=rofi&logoColor=white&labelColor=302D41" alt="Launcher"></a>
  </p>
</div>

Hello.  This is the Notes directory.  Every file here is a plain markdown note, created and managed from the rofi sidebar (`SUPER + SHIFT + N`).

No database.  No sync.  No bloat.  Just files.


## How It Works

The notes sidebar shows three options:

| Icon | Action | What It Does |
|------|--------|-------------|
| 󰅴 | New Note | Asks for a title, opens `kitty -e nvim ~/BlackNode/Notes/<title>.md` |
| 󰋼 | View Notes | Lists all `.md` files sorted by date (newest first), pick one to edit |
| 󰋁 | Open Folder | Opens `~/BlackNode/Notes/` directly in neovim |

That is it.  Three actions, zero friction.


## File Naming

- If you provide a title, spaces become hyphens: `"my idea"` → `my-idea.md`
- If you leave the title empty, it uses the current timestamp: `2026-07-10-1430.md`
- All files sit flat in this directory — no subfolders, no nesting


## The Script

The logic lives in `~/.config/rofi/scripts/notes.sh`.  Simple bash, nothing fancy:

```
rofi sidebar → pick action → neovim
```


## Notes

- Markdown only (`.md`).  You can write anything — code, todos, journal entries, config snippets.
- No search index, no tags, no metadata.  The list view shows filename + last-modified date.
- To move or delete a note, use your file manager (or `rm` in the terminal).

