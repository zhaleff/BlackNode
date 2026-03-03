<h1 align="center">HollowSec's ZSH Plugin Collection</h1>

<div align="center">
  <p>
    <a href="#"><img src="https://img.shields.io/badge/plugins-10-blue?style=for-the-badge&logo=zsh&logoColor=white&labelColor=302D41&color=89B4FA" alt="Plugins"></a>&nbsp;&nbsp;
    <a href="#"><img src="https://img.shields.io/badge/last%20updated-2025--03--02-green?style=for-the-badge&logo=github&logoColor=white&labelColor=302D41&color=A6E3A1" alt="Last Updated"></a>&nbsp;&nbsp;
    <a href="#"><img src="https://img.shields.io/badge/license-MIT-yellow?style=for-the-badge&logo=open-source-initiative&logoColor=white&labelColor=302D41&color=F9E2AF" alt="License"></a>&nbsp;&nbsp;
    <a href="#"><img src="https://img.shields.io/badge/shell-ZSH-brightgreen?style=for-the-badge&logo=gnu-bash&logoColor=white&labelColor=302D41&color=CBA6F7" alt="Shell"></a>
  </p>
</div>

Hello.  This is my configuration favourite for ZSH and Plugins.  I’ve spent countless hours curating, testing, and falling in love with each of these little gems.  They transform a humble shell into something that feels almost magical—like having a personal assistant who knows exactly what you’re about to type, corrects your mistakes before you make them, and paints your commands in brilliant colours.

Whether you’re a seasoned sysadmin, a developer who lives in the terminal, or just someone who wants their command line to feel less like a 1970s teletype and more like a modern, efficient workspace, this collection will make you smile.  Let’s take a tour, shall we?

---

## Table of Contents
- [Plugins](#plugins)
  - [zsh-autosuggestions](#zsh-autosuggestions)
  - [zsh-autopair](#zsh-autopair)
  - [zsh-syntax-highlighting](#zsh-syntax-highlighting)
  - [fzf-tab](#fzf-tab)
  - [zsh-you-should-use](#zsh-you-should-use)
  - [zsh-fzf-history-search](#zsh-fzf-history-search)
  - [zsh-history-substring-search](#zsh-history-substring-search)
  - [zsh-completions](#zsh-completions)
  - [fzf-zsh-plugin](#fzf-zsh-plugin)
  - [fzf (system integrations)](#fzf-system-integrations)
- [Beyond the Plugins](#beyond-the-plugins)
- [Get Started](#get-started)

---

## Plugins

### zsh-autosuggestions
[![GitHub](https://img.shields.io/badge/github-zsh--users/zsh--autosuggestions-181717?style=flat-square&logo=github&labelColor=302D41&color=89B4FA)](https://github.com/zsh-users/zsh-autosuggestions)

**What it does:**  
As you type, it suggests commands from your history, appearing in a subdued grey.  Press the right arrow key (or our custom keybind `Alt+Z`) to accept the suggestion and complete the command instantly.

**Why you’ll love it:**  
It’s like having a mind reader in your terminal.  Long, complex commands you use every day become effortless.  No more scrolling through history or retyping the same thing twice.

**In our config:**  
Bound to `Alt+Z` for one‑tap acceptance, and integrated with the theme for perfect colour matching.

---

### zsh-autopair
[![GitHub](https://img.shields.io/badge/github-hlissner/zsh--autopair-181717?style=flat-square&logo=github&labelColor=302D41&color=89B4FA)](https://github.com/hlissner/zsh-autopair)

**What it does:**  
Automatically inserts the closing character for quotes, brackets, and parentheses as you type.  It also handles deleting both characters when you backspace over the opening one.

**Why you’ll love it:**  
No more hunting for the right key or leaving unclosed strings.  It’s a tiny thing, but it makes coding and scripting feel fluid and natural.

**In our config:**  
Works out of the box, no extra setup needed.  Just type and forget.

---

### zsh-syntax-highlighting
[![GitHub](https://img.shields.io/badge/github-zsh--users/zsh--syntax--highlighting-181717?style=flat-square&logo=github&labelColor=302D41&color=89B4FA)](https://github.com/zsh-users/zsh-syntax-highlighting)

**What it does:**  
As you type commands, valid ones turn green, invalid ones turn red, and special arguments are highlighted in different colours.  It’s like having a real‑time syntax checker right in your prompt.

**Why you’ll love it:**  
Mistakes become immediately obvious.  You’ll never hit Enter on a command that’s clearly broken again.  It also makes the terminal look vibrant and alive.

**In our config:**  
Loaded after other plugins to ensure it doesn’t conflict, and styled to match the Powerlevel10k theme.

---

### fzf-tab
[![GitHub](https://img.shields.io/badge/github-Aloxaf/fzf--tab-181717?style=flat-square&logo=github&labelColor=302D41&color=89B4FA)](https://github.com/Aloxaf/fzf-tab)

**What it does:**  
Replaces ZSH’s default tab completion with a fuzzy finder interface.  When you press Tab, a list appears that you can navigate with arrow keys or type to filter.  It even shows previews for files.

**Why you’ll love it:**  
Tab completion becomes a pleasure, not a chore.  Finding that deeply nested file or obscure command option is fast and intuitive.  The preview window is a game changer.

**In our config:**  
Integrated with fzf and styled with our colour scheme.  Group names are shown in cyan, making it easy to distinguish categories.

---

### zsh-you-should-use
[![GitHub](https://img.shields.io/badge/github-MichaelAquilina/zsh--you--should--use-181717?style=flat-square&logo=github&labelColor=302D41&color=89B4FA)](https://github.com/MichaelAquilina/zsh-you-should-use)

**What it does:**  
When you type a command that has a shorter or more efficient alias available, it gently reminds you: “You should use: [alias]”.

**Why you’ll love it:**  
It helps you discover and remember the aliases you’ve set (like `gs` for `git status`).  Over time, you’ll type faster and smarter without even trying.

**In our config:**  
Works silently in the background, only chiming in when it can genuinely save you keystrokes.

---

### zsh-fzf-history-search
[![GitHub](https://img.shields.io/badge/github-joshskidmore/zsh--fzf--history--search-181717?style=flat-square&logo=github&labelColor=302D41&color=89B4FA)](https://github.com/joshskidmore/zsh-fzf-history-search)

**What it does:**  
Enhances Ctrl+R history search with an fzf interface.  Instead of cycling through matches, you get a fuzzy searchable list of your entire history, with a preview of each command.

**Why you’ll love it:**  
Finding that command you ran three weeks ago becomes instantaneous.  Type a keyword, see all matches, pick the one you want, and it’s inserted at the prompt.

**In our config:**  
Bound to `Ctrl+R`, overriding the default history search.

---

### zsh-history-substring-search
[![GitHub](https://img.shields.io/badge/github-zsh--users/zsh--history--substring--search-181717?style=flat-square&logo=github&labelColor=302D41&color=89B4FA)](https://github.com/zsh-users/zsh-history-substring-search)

**What it does:**  
Allows you to search your history by typing part of a command and pressing Up/Down arrows to cycle through matches that contain that substring.

**Why you’ll love it:**  
It’s a classic, efficient way to recall commands without leaving the home row.  Combined with fzf, you get the best of both worlds.

**In our config:**  
Bound to Up and Down arrows, and works seamlessly with the other history plugins.

---

### zsh-completions
[![GitHub](https://img.shields.io/badge/github-zsh--users/zsh--completions-181717?style=flat-square&logo=github&labelColor=302D41&color=89B4FA)](https://github.com/zsh-users/zsh-completions)

**What it does:**  
Adds thousands of extra completion definitions for commands like git, docker, ssh, and many more.  It extends ZSH’s already powerful completion system.

**Why you’ll love it:**  
Tab completion becomes context‑aware.  For example, typing `git checkout ` and pressing Tab shows you branch names.  It just knows what you want.

**In our config:**  
Added to `fpath` early so its completions take precedence.

---

### fzf-zsh-plugin
[![GitHub](https://img.shields.io/badge/github-urbainvaes/fzf--zsh--plugin-181717?style=flat-square&logo=github&labelColor=302D41&color=89B4FA)](https://github.com/urbainvaes/fzf-zsh-plugin)

**What it does:**  
Provides several useful widgets powered by fzf: changing directories with `**`, killing processes, searching files, and more.

**Why you’ll love it:**  
It brings fzf’s fuzzy finding to everyday tasks.  For instance, type `cd **` and press Tab to interactively choose a directory.  It’s incredibly handy.

**In our config:**  
All widgets are available, and we’ve bound `Alt+^C` to `fzf-cd-widget` for quick directory jumping.

---

### fzf (system integrations)
**Files:** `/usr/share/fzf/key-bindings.zsh`, `/usr/share/fzf/completion.zsh`

**What it does:**  
The official fzf integration for ZSH.  Adds `Ctrl+T` to paste selected files/directories, `Ctrl+R` (if not overridden) for history, and `Alt+C` to cd into a selected directory.

**Why you’ll love it:**  
It’s the foundation for many fzf‑powered features, and works beautifully with the other plugins.

**In our config:**  
We keep `Ctrl+T` for file widgets and override `Ctrl+R` with the enhanced history search.  `Alt+C` remains for directory jumping, but we also have our own `Alt+^C` for fzf‑cd.

---

## Beyond the Plugins

Of course, a great shell isn’t just about plugins.  Here are some extra touches that make this config truly special:

- **Key Bindings:**  
  We’ve carefully mapped keys for efficiency.  Home/End go to start/end of line, Delete works as expected, and we’ve even bound `Alt+Z` to accept autosuggestions.

- **Shell Options:**  
  History is shared across sessions, duplicates are ignored, and you can use `# comments` in interactive commands.  Auto‑cd means you can just type a directory name to enter it.

- **Completion Styling:**  
  Menus are colourful, grouped, and case‑insensitive with smart matching.  Descriptions pop in cyan.

- **Aliases:**  
  From `la` for a colourful file listing to `gs` for git status, every alias is chosen to save time and reduce typing.  The `extract` function handles nearly any archive with one command.

- **Prompt:**  
  Powerlevel10k gives you a lightning‑fast, infinitely customisable prompt that shows git status, exit codes, and more, all in a clean, atomic design.

---

## Get Started

This configuration is the result of years of tweaking and obsession.  Every plugin, every option, every binding exists to make your time in the terminal more productive, more pleasant, and more fun.  Try it for a week, and you’ll wonder how you ever lived without it.

If you have questions, suggestions, or just want to share your own favourite plugins, feel free to reach out.  The terminal is a personal space, and this is mine—but I’m happy to help you build yours.

Happy hacking.

**— HollowSec**
