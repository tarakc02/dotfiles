# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository containing shell configurations, neovim setup, tmux config, email tooling, and utility scripts.

## Structure

- `bash_profile`, `zshrc` - Shell configurations (bash preferred, zsh for Mac compatibility)
- `nvim/` - Neovim configuration with vim-plug plugins
- `tmux/` - Tmux configuration with machine-specific overrides
- `email/` - Neomutt email setup using mbsync, notmuch, and msmtp (macOS only)
- `scripts/` - Utility scripts including the `my` multi-tool
- `claude/skills/` - Claude Code skills for MCP server building and skill creation

## Key Configuration Details

### Neovim (`nvim/vimrc`)
- Uses vim-plug for plugin management (`:PlugInstall` to install)
- Local leader is `,` (comma)
- coc.nvim for LSP completion; Copilot for AI assistance
- hlterm plugin for REPL integration: `<LocalLeader>s` starts REPL, `<Space>` sends code
- R.nvim for R development, vimtex for LaTeX
- UltiSnips for snippets (`<C-s>` to expand, `<C-j>`/`<C-k>` to navigate)
- fzf integration for fuzzy finding
- Everforest colorscheme
- Custom snippets in `nvim/snippets/`

### Tmux (`tmux/tmux.conf`)
- Prefix is `C-Space` (not default C-b)
- Vim-style pane navigation: `C-h/j/k/l`
- Window splits: `C-v` (vertical), `C-s` (horizontal), `C-n` (new window)
- `F12` toggles keybindings off (for nested sessions)
- `C-w` opens weekly notes
- Sources `~/.tmux-local.conf` for machine-specific settings

### Shell Environment
- Editor set to nvim; aliases vim to nvim if available
- Uses zoxide for directory jumping (`j` alias for `zi`)
- fzf completion trigger is `?`
- Environment variable `HRDAG_GIT_HOME=~/git` for project organization

### The `my` Script (`scripts/my`)
Multi-purpose CLI tool. Key actions:
- `my root` - Show git project root
- `my ggrep` / `my rgrep` - Git grep / recursive grep
- `my task <name>` - Create task directory structure (src/, input/, output/)
- `my week` - Open weekly notes in Goyo mode
- `my show <query>` / `my reply <query>` - Show/reply to email via notmuch
- `my preview-rmd` / `my preview-md` - Preview Rmarkdown or markdown files

### Email Setup (macOS)
Uses neomutt with mbsync (sync), notmuch (search/index), and msmtp (send). Config files in `email/`. Sync runs via launchd service every 2 minutes.
