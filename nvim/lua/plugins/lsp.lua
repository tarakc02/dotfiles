return {
  -- LSP config
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
    },
    config = function()
      -- Keymaps set on LSP attach
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc })
          end
          map("n", "<LocalLeader>d", vim.lsp.buf.definition, "Go to definition")
          map("n", "<LocalLeader>r", vim.lsp.buf.references, "References")
          map("n", "K", vim.lsp.buf.hover, "Hover documentation")
          map("n", "<LocalLeader>a", vim.lsp.buf.code_action, "Code action")
          map("n", "<LocalLeader>rn", vim.lsp.buf.rename, "Rename symbol")
          map("n", "<LocalLeader>e", vim.diagnostic.open_float, "Diagnostics float")
          map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
          map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
        end,
      })
    end,
  },

  -- Package manager for LSP servers, formatters, linters
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    opts = {},
  },

  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = {
        "pyright",
        "lua_ls",
        "r_language_server",
        "texlab",
        "bashls",
      },
      automatic_installation = true,
      handlers = {
        r_language_server = function()
          require("lspconfig").r_language_server.setup({
            cmd_env = {
              -- Set R option so lintr always finds ~/.lintr
              R_PROFILE_USER = vim.fn.expand("~/.Rprofile_lsp"),
            },
          })
        end,
      },
    },
  },

  -- Completion engine
  {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
    },
    opts = {
      keymap = {
        preset = "default",
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<C-l>"] = { "show" },
        ["<C-e>"] = { "cancel" },
        ["<C-d>"] = { "scroll_documentation_down" },
        ["<C-u>"] = { "scroll_documentation_up" },
      },
      completion = {
        documentation = { auto_show = true },
        ghost_text = { enabled = false },
        menu = {
          draw = {
            columns = {
              { "kind" },
              { "label", "label_description", gap = 1 },
              { "source_name" },
            },
          },
        },
      },
      snippets = { preset = "luasnip" },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          path = {
            opts = {
              show_hidden_files_by_default = false,
              get_cwd = function(_) return vim.fn.getcwd() end,
            },
          },
        },
      },
    },
  },

  -- Snippet engine
  {
    "L3MON4D3/LuaSnip",
    version = "2.*",
    build = "make install_jsregexp",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      local ls = require("luasnip")
      ls.setup({
        history = true,
        updateevents = "TextChanged,TextChangedI",
      })

      -- Load friendly-snippets (VSCode format)
      require("luasnip.loaders.from_vscode").lazy_load()

      -- Load custom snippets (snipmate format, in my-snippets/)
      require("luasnip.loaders.from_snipmate").lazy_load({
        paths = { vim.fn.stdpath("config") .. "/my-snippets" },
      })

      -- Snippet navigation (preserving your C-j/C-k muscle memory)
      vim.keymap.set({ "i", "s" }, "<C-j>", function()
        if ls.expand_or_jumpable() then ls.expand_or_jump() end
      end, { desc = "Snippet forward" })
      vim.keymap.set({ "i", "s" }, "<C-k>", function()
        if ls.jumpable(-1) then ls.jump(-1) end
      end, { desc = "Snippet backward" })
      vim.keymap.set({ "i", "s" }, "<C-s>", function()
        if ls.expandable() then ls.expand() end
      end, { desc = "Expand snippet" })
    end,
  },
}
