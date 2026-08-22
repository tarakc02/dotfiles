-- Local code autocomplete via the vLLM server in ~/git/scott-code-autocomplete
-- (Qwen2.5-Coder-7B on http://127.0.0.1:8923). Ghost text, like Copilot.
--
-- Note: vLLM's /v1/completions rejects a `suffix` field, so the Qwen FIM prompt
-- is assembled client-side (template.prompt) with suffix sending disabled.
return {
  {
    "milanglacier/minuet-ai.nvim",
    -- This is the active ghost-text provider and owns <Tab>. Copilot's ghost
    -- text is off in plugins/ai.lua; see there for how to swap them back.
    enabled = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    -- Load on FileType (NOT InsertEnter): minuet registers a FileType autocmd
    -- that sets the per-buffer auto-trigger flag. lazy re-fires FileType after
    -- loading, so the flag gets set for the buffer that triggered the load.
    -- Keep this list in sync with virtualtext.auto_trigger_ft below.
    ft = { "python", "r", "rmd", "lua", "rust", "sh", "julia", "sql" },
    opts = {
      n_completions = 1, -- one request at a time keeps the single GPU responsive
      context_window = 2000, -- chars of surrounding code sent before/after cursor
      provider = "openai_fim_compatible",

      provider_options = {
        openai_fim_compatible = {
          name = "scott",
          end_point = "http://127.0.0.1:8923/v1/completions",
          model = "Qwen2.5-Coder-7B",
          -- vLLM wants *some* bearer token but doesn't validate it. This is the
          -- NAME of an env var that exists (TERM always does), not the value.
          api_key = "KJ_API_KEY",
          stream = true,

          template = {
            prompt = function(prefix, suffix, _)
              return "<|fim_prefix|>" .. prefix .. "<|fim_suffix|>" .. suffix .. "<|fim_middle|>"
            end,
            suffix = false, -- do NOT send a suffix field; vLLM rejects it
          },

          optional = {
            max_tokens = 256,
            temperature = 0.2,
            top_p = 0.9,
            stop = { "<|endoftext|>", "<|fim_pad|>", "<|file_sep|>", "<|fim_prefix|>" },
          },
        },
      },

      virtualtext = {
        auto_trigger_ft = { "python", "r", "rmd", "lua", "rust", "sh", "julia", "sql" },
        -- Terminal-safe keys only: <A-…> (Alt) chords usually don't reach
        -- Neovim in a terminal, so Ctrl combos are used instead.
        keymap = {
          -- accept is bound to <Tab> in config() below, not here: minuet's own
          -- accept keymap is a silent no-op when no suggestion is showing,
          -- which would swallow indentation.
          accept = false,
          accept_line = "<C-Down>", -- accept one line
          next = false, -- n_completions=1, so cycling is unused
          prev = false,
          dismiss = false, -- auto-dismisses on cursor move / leaving insert mode
        },
        show_on_completion_menu = false,
      },
    },
    config = function(_, opts)
      require("minuet").setup(opts)

      -- <Tab> is ghost text's key and nothing else's: blink's snippet_forward
      -- claim on it is disabled in plugins/lsp.lua, and LuaSnip jumps live on
      -- <C-j>/<C-k>. With no suggestion visible it inserts a plain Tab.
      vim.keymap.set("i", "<Tab>", function()
        local vt = require("minuet.virtualtext").action
        if vt.is_visible() then
          vt.accept()
        else
          vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes("<Tab>", true, false, true),
            "n", false)
        end
      end, { desc = "Accept ghost text / insert Tab" })
    end,
  },
}
