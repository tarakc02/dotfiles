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

  -- Keybinding help popup (toggle with :WhichKey to show, disabled auto-popup)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      icons = { mappings = false, keys = {} },
      triggers = {
        { "<leader>", mode = { "n", "v" } },
        { "<LocalLeader>", mode = { "n", "v" } },
      },
      plugins = { spelling = { enabled = true } },
    },
    keys = {
      {
        "<leader>?",
        function() require("which-key").show({ global = false }) end,
        desc = "Buffer-local keymaps",
      },
    },
  },
}
