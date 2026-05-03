return {
  -- Colorscheme
  {
    "sainnhe/everforest",
    priority = 1000,
    config = function()
      vim.g.everforest_background = "hard"
      vim.cmd.colorscheme("everforest")
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        theme = "everforest",
        icons_enabled = false,
        component_separators = { left = "|", right = "|" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          { function() return vim.fn.fnamemodify(vim.fn.getcwd(), ":~") end },
        },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      tabline = {
        lualine_a = {
          {
            "buffers",
            icons_enabled = false,
            show_filename_only = true,
            show_modified_status = true,
            mode = 2, -- show buffer number + name
          },
        },
        lualine_z = { "tabs" },
      },
    },
  },

  -- Fuzzy finder (reuses existing fzf binary)
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    keys = {
      { "<C-p>", "<cmd>FzfLua files<CR>", desc = "Find files" },
      { "<C-f>", "<cmd>FzfLua live_grep<CR>", desc = "Live grep" },
      { "<LocalLeader>b", "<cmd>FzfLua buffers<CR>", desc = "Buffers" },
      { "<LocalLeader>h", "<cmd>FzfLua help_tags<CR>", desc = "Help tags" },
      { "<LocalLeader>f", "<cmd>FzfLua git_files<CR>", desc = "Git files" },
    },
    opts = {
      fzf_bin = vim.fn.expand("~/git/fzf/bin/fzf"),
      winopts = { height = 0.85, width = 0.80 },
    },
  },
}
