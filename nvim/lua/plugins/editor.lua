return {
  -- Surround text objects
  { "tpope/vim-surround" },

  -- Repeat plugin operations with .
  { "tpope/vim-repeat" },

  -- Alignment
  { "godlygeek/tabular", cmd = "Tabularize" },

  -- File explorer (edit filesystem like a buffer)
  {
    "stevearc/oil.nvim",
    keys = {
      { "-", "<cmd>Oil<CR>", desc = "Open parent directory" },
    },
    opts = {
      view_options = { show_hidden = true },
      keymaps = {
        ["q"] = "actions.close",
        ["<C-h>"] = false, -- don't conflict with window nav
        ["<C-l>"] = false,
      },
    },
  },

  -- Keybinding help popup (disabled)
  {
    "folke/which-key.nvim",
    enabled = false,
  },
}
