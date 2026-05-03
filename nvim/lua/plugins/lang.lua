return {
  -- Treesitter (syntax highlighting, textobjects, folding)
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = {
          "bash", "c", "lua", "python", "r", "julia",
          "latex", "bibtex", "markdown", "markdown_inline",
          "sql", "json", "yaml", "toml", "vim", "vimdoc",
          "html", "css", "javascript",
        },
      })

      -- Enable treesitter highlighting
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },

  -- REPL integration (R, Python, Julia)
  {
    "jalvesaq/hlterm",
    config = function()
      require("hlterm").setup({
        app = {
          python = "uv run python",
          julia = "julia --threads=auto --project=@. -O3",
        },
        mappings = {
          start = "<LocalLeader>s",
          send = "<Space>",
        },
      })
    end,
  },

  -- R development
  {
    "R-nvim/R.nvim",
    ft = { "r", "rmd", "rnoweb", "rhelp", "rdoc" },
    config = function()
      vim.g.R_assign = 0
      vim.g.R_nvim_wd = 1

      -- R.nvim keymaps
      vim.keymap.set("v", "<Space>", "<Plug>RDSendSelection", { desc = "Send selection to R" })
      vim.keymap.set("n", "<Space>", "<Plug>RDSendLine", { desc = "Send line to R" })
      vim.keymap.set({ "n", "v" }, "<LocalLeader>c", "<Plug>RToggleComment", { desc = "Toggle R comment" })
    end,
  },

  -- LaTeX
  {
    "lervag/vimtex",
    ft = { "tex", "latex", "plaintex" },
  },

  -- Database client
  {
    "tpope/vim-dadbod",
    cmd = "DB",
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = { "tpope/vim-dadbod" },
    cmd = { "DBUI", "DBUIToggle" },
    init = function()
      vim.g.db_ui_execute_on_save = 0
    end,
  },
}
