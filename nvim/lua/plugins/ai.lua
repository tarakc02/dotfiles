return {
  -- Multi-provider AI chat and inline editing
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
    keys = {
      { "<LocalLeader>cc", "<cmd>CodeCompanionChat Toggle<CR>", mode = { "n", "v" }, desc = "AI Chat" },
      { "<LocalLeader>ca", "<cmd>CodeCompanionActions<CR>", mode = { "n", "v" }, desc = "AI Actions" },
      { "<LocalLeader>ci", "<cmd>CodeCompanion<CR>", mode = { "n", "v" }, desc = "AI Inline" },
      { "ga", "<cmd>CodeCompanionChat Add<CR>", mode = "v", desc = "Add to AI chat" },
    },
    opts = {
      strategies = {
        -- Uses Claude Max subscription via ACP (no API key needed)
        chat = { adapter = "claude_code" },
        inline = { adapter = "claude_code" },
        cmd = { adapter = "claude_code" },
      },
      adapters = {
        -- Claude via Claude Code ACP (uses your Max subscription)
        claude_code = function()
          return require("codecompanion.adapters").extend("claude_code", {})
        end,
        -- Claude via Copilot (uses Copilot subscription)
        copilot = function()
          return require("codecompanion.adapters").extend("copilot", {
            schema = {
              model = { default = "claude-sonnet-4-5-20250514" },
            },
          })
        end,
        -- Local models via Ollama
        ollama = function()
          return require("codecompanion.adapters").extend("ollama", {
            schema = {
              model = { default = "llama3.2" },
            },
          })
        end,
        -- Direct Anthropic API (pay-per-token, if needed)
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            schema = {
              model = { default = "claude-sonnet-4-20250514" },
            },
          })
        end,
      },
      display = {
        chat = {
          window = { layout = "vertical", width = 0.4 },
        },
        diff = { provider = "mini_diff" },
      },
    },
  },

  -- Copilot ghost-text completion
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<Tab>",
          accept_word = false,
          accept_line = false,
          next = "<C-n>",
          prev = "<C-p>",
          dismiss = false,
        },
      },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        mail = false,
      },
    },
  },
}
