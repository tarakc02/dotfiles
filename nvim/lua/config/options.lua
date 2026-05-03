local opt = vim.opt
local g = vim.g

-- Leader keys
g.maplocalleader = ","

-- Python host (uv-managed)
g.python3_host_prog = vim.fn.expand("~/bin/uv-python")

-- Shell
opt.shell = "bash"

-- Basic options
opt.hidden = true
opt.exrc = true
opt.cursorline = true
opt.termguicolors = true
opt.signcolumn = "number"

-- Tabs
opt.tabstop = 4
opt.softtabstop = 0
opt.expandtab = true
opt.shiftwidth = 4
opt.smarttab = true
opt.smartindent = true

-- Folding
opt.foldmethod = "marker"
opt.foldmarker = "{{{,}}}"
opt.foldlevel = 0
opt.foldcolumn = "4"

-- Layout
opt.relativenumber = true
opt.number = true
opt.colorcolumn = "80"
opt.list = true
opt.listchars = { tab = "▸ ", eol = "¬", nbsp = "·", trail = "·" }

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.grepprg = "rg --vimgrep --smart-case"

-- Completion
opt.completeopt = { "noinsert", "menuone", "noselect" }

-- Cursor shape
opt.guicursor = "n-v-c:block-Cursor/lCursor-blinkon0,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor"

-- Diagnostics: show inline, don't clutter the gutter
vim.diagnostic.config({
  signs = false,           -- no gutter signs (E/W)
  virtual_text = false,
  underline = false,       -- underline the problematic code
  update_in_insert = false,
  severity_sort = true,
})
