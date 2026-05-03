# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles repository containing shell configurations, neovim setup, tmux config, email tooling, and Claude Code skills.

## Structure

- `bash_profile` - Bash configuration (primary shell on Linux)
- `zshrc` - Zsh configuration (macOS compatibility, largely outdated)
- `nvim/` - Neovim configuration using **lazy.nvim** plugin manager
  - `init.lua` - Entry point, boots lazy.nvim
  - `lua/config/` - Core config (options.lua, keymaps.lua, autocmds.lua)
  - `lua/plugins/` - Plugin specs (ai.lua, lsp.lua, editor.lua, ui.lua, lang.lua, writing.lua, git.lua)
  - `snippets/` - Custom UltiSnips/snipmate-format snippets (symlinked to `~/.config/nvim/my-snippets/`)
- `tmux/` - Tmux configuration with machine-specific overrides
  - `tmux.conf` - Base config, sources `~/.tmux-local.conf`
  - Machine-specific files (e.g. tmux-eleanor.conf, tmux-butterfly.conf)
- `email/` - Neomutt email setup (macOS only)
- `scripts/` - Utility scripts including the `my` multi-tool
- `claude/skills/` - Claude Code skills (mcp-builder, skill-creator, labeling-interface, legal-research, literature-review, information-resource-design, hrdag-workflow)

## Key Configuration Details

### Neovim (`nvim/init.lua`)
- Uses **lazy.nvim** for plugin management
- Local leader is `,` (comma)
- **CodeCompanion** for AI chat/inline editing (multiple adapters configured: opencode ACP, Copilot Claude, local kj LLM endpoint, direct Anthropic API)
- Custom `:Stub` and `:Implement` commands for code generation
- **Copilot** for ghost-text completions (`<Tab>` to accept)
- **blink.cmp** for LSP completion engine; **LuaSnip** for snippets (`<C-s>` expand, `<C-j>`/`<C-k>` navigate)
- **LSP** via mason / nvim-lspconfig (pyright, lua_ls, r_language_server, texlab, bashls)
- **Treesitter** for syntax highlighting and folding
- **hlterm** for REPL integration: `<LocalLeader>s` starts REPL, `<Space>` sends code
- **R.nvim** for R development, **vimtex** for LaTeX
- **vim-fugitive** for Git integration
- **fzf-lua** for fuzzy finding (`<C-p>` files, `<C-f>` live grep)
- **lualine** for statusline/tabline
- **Everforest** colorscheme
- Custom snippets in `nvim/snippets/` (snipmate format, loaded via LuaSnip from `~/.config/nvim/my-snippets/`)

### Tmux (`tmux/tmux.conf`)
- Prefix is `C-Space` (not default C-b)
- Vim-style pane navigation: `C-h/j/k/l`
- Window splits: `C-v` (vertical), `C-s` (horizontal), `C-n` (new window)
- `F12` toggles all keybindings off (for nested sessions) — disables prefix, dims status bar
- `C-w` opens weekly notes
- Sources `~/.tmux-local.conf` for machine-specific settings
- Machine configs in `tmux/` directory (e.g. tmux-eleanor.conf, tmux-butterfly.conf)
- `extended-keys on` can be set per-session for kitty keyboard protocol support

### Shell Environment (`bash_profile`)
- Editor set to nvim; aliases vim to nvim
- Uses **zoxide** for directory jumping (`j` alias for `zi`)
- **fzf** completion trigger is `?`
- Environment variable `HRDAG_GIT_HOME=~/git`
- Sources `~/.local-bash-env` for machine-specific env (homebrew, conda paths)
- Activates micromamba base if available
- Sources `~/.fzf.bash` for fzf shell integration

### The `my` Script (`scripts/my`)
Multi-purpose CLI tool. Key actions:
- `my root` - Show git project root
- `my ggrep` / `my rgrep` - Git grep / recursive grep
- `my task <name>` - Create task directory structure (src/, input/, output/)
- `my week` - Open weekly notes in Goyo mode
- `my show <query>` / `my reply <query>` - Show/reply to email via notmuch
- `my preview-rmd` / `my preview-md` - Preview Rmarkdown or markdown files

### Email Setup (macOS)
Uses neomutt with mbsync (sync), notmuch (search/index), and msmtp (send). Config files in `email/`. Sync via launchd every 2 minutes.
