local language_conventions = {
  python = {
    name = "Python",
    docstring = "NumPy-style",
    types = "modern PEP 604 unions (X | None, list[int]), typing for generics",
    stub_body = "raise NotImplementedError",
    extra = "Use `from __future__ import annotations` style; no runtime imports in the stub.",
  },
  r = {
    name = "R",
    docstring = "roxygen2-style (#' @param, #' @return)",
    types = "no static types; document expected types in roxygen",
    stub_body = 'stop("Not implemented")',
    extra = "Follow tidyverse style. Use <- for assignment.",
  },
  julia = {
    name = "Julia",
    docstring = 'a docstring block with """..."""',
    types = "type annotations on arguments and return type where meaningful",
    stub_body = 'error("Not implemented")',
    extra = "Prefer multiple dispatch idioms.",
  },
  lua = {
    name = "Lua",
    docstring = "LuaLS / EmmyLua annotations (---@param, ---@return)",
    types = "LuaLS annotation comments above the function",
    stub_body = 'error("Not implemented")',
    extra = "",
  },
  rust = {
    name = "Rust",
    docstring = "///-style doc comments with # Arguments / # Returns sections",
    types = "full type signatures; use Result<T, E> where fallible",
    stub_body = "todo!()",
    extra = "",
  },
  sh = {
    name = "Bash",
    docstring = "a leading comment block documenting args and return code",
    types = "document expected arg types/shapes in the comment",
    stub_body = 'echo "not implemented" >&2; return 1',
    extra = "Use POSIX-compatible syntax unless bashisms are clearly intended.",
  },
  _default = {
    name = "the target language",
    docstring = "the idiomatic docstring style for this language",
    types = "idiomatic type annotations if the language supports them",
    stub_body = "an appropriate 'not implemented' sentinel",
    extra = "",
  },
}

local function conventions_for(filetype)
  return language_conventions[filetype] or language_conventions._default
end

local function buffer_lines(bufnr, start_line, end_line)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return {}
  end
  return vim.api.nvim_buf_get_lines(bufnr, start_line, end_line, false)
end

local function full_buffer(context)
  return table.concat(buffer_lines(context.bufnr, 0, -1), "\n")
end

-- The kj vLLM endpoint rejects requests with more than one system message
-- ("System message must be at the beginning."). Merge them into a single
-- leading system message before delegating to the OpenAI form_messages handler.
local function merge_system_messages(self, messages)
  local system_parts, other = {}, {}
  for _, msg in ipairs(messages) do
    if msg.role == "system" then
      table.insert(system_parts, msg.content)
    else
      table.insert(other, msg)
    end
  end
  local merged = {}
  if #system_parts > 0 then
    table.insert(merged, { role = "system", content = table.concat(system_parts, "\n\n") })
  end
  for _, msg in ipairs(other) do
    table.insert(merged, msg)
  end
  return require("codecompanion.adapters.http.openai").handlers.form_messages(self, merged)
end

local function buffer_minus_selection(context)
  local before = buffer_lines(context.bufnr, 0, (context.start_line or 1) - 1)
  local after = buffer_lines(context.bufnr, context.end_line or 0, -1)
  local parts = {}
  if #before > 0 then table.insert(parts, table.concat(before, "\n")) end
  table.insert(parts, "[... stub being implemented appears here ...]")
  if #after > 0 then table.insert(parts, table.concat(after, "\n")) end
  return table.concat(parts, "\n")
end

return {
  -- Multi-provider AI chat and inline editing
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions", "Stub", "Implement" },
    keys = {
      { "<LocalLeader>cc", "<cmd>CodeCompanionChat Toggle<CR>", mode = { "n", "v" }, desc = "AI Chat" },
      { "<LocalLeader>ca", "<cmd>CodeCompanionActions<CR>", mode = { "n", "v" }, desc = "AI Actions" },
      { "<LocalLeader>ci", "<cmd>CodeCompanion<CR>", mode = { "n", "v" }, desc = "AI Inline" },
      { "ga", "<cmd>CodeCompanionChat Add<CR>", mode = "v", desc = "Add to AI chat" },
    },
    opts = {
      strategies = {
        chat = { adapter = "opencode" },
        inline = { adapter = "kj_gemma" },
        cmd = { adapter = "kj_gemma" },
      },
      adapters = {
        acp = {
          -- Claude via Claude Code ACP (uses your Max subscription)
          claude_code = function()
            return require("codecompanion.adapters").extend("claude_code", {})
          end,
          opencode = function()
              return require("codecompanion.adapters").extend("opencode", {})
          end,
        },
        http = {
          -- Claude via Copilot (uses Copilot subscription)
          copilot = function()
            return require("codecompanion.adapters").extend("copilot", {
              schema = {
                model = { default = "claude-sonnet-4-5-20250514" },
              },
            })
          end,
          -- Local models via the kj OpenAI-compatible endpoint
          kj_gemma = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
              formatted_name = "kj-gemma",
              env = {
                url = "http://kj/llm",
                api_key = "KJ_API_KEY",
                chat_url = "/v1/chat/completions",
              },
              schema = {
                model = { default = "gemma" },
              },
              handlers = {
                form_messages = merge_system_messages,
              },
            })
          end,
          kj_qwen = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
              formatted_name = "kj-qwen",
              env = {
                url = "http://kj/llm",
                api_key = "KJ_API_KEY",
                chat_url = "/v1/chat/completions",
              },
              schema = {
                model = { default = "qwen" },
              },
              handlers = {
                form_messages = merge_system_messages,
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
      },
      display = {
        chat = {
          window = { layout = "vertical", width = 0.4 },
        },
        diff = { provider = "mini_diff" },
      },
      prompt_library = {
        ["Stub"] = {
          strategy = "inline",
          description = "Generate a function stub with types and docstring",
          opts = {
            alias = "stub",
            auto_submit = true,
            placement = "add",
            adapter = { name = "kj_qwen" },
          },
          prompts = {
            {
              role = "system",
              content = function(context)
                local c = conventions_for(context.filetype)
                return string.format([[
You are a %s code generator.
Produce ONLY a function signature with:
- %s
- A concise %s docstring
- Body: %s

%s

The user may include a <file_context> block showing the surrounding file. Use it to:
- Match naming conventions and style.
- Reference helpers, classes, or types defined elsewhere in the file.
- Avoid duplicating something that already exists.
Do NOT copy code from <file_context> into your output. Output only the new stub.

Output rules:
- No markdown code fences.
- No surrounding prose, no "Here is..." preamble.
- No example usage.
- Just the stub, ready to paste into a %s file.
]], c.name, c.types, c.docstring, c.stub_body, c.extra, c.name)
              end,
            },
            {
              role = "user",
              content = function(context)
                local file_ctx = full_buffer(context)
                return string.format(
                  "Language: %s\nFile: %s\n\n<file_context>\n%s\n</file_context>\n\nCreate a stub for: %s",
                  context.filetype,
                  context.filename or "",
                  file_ctx,
                  context.user_prompt or ""
                )
              end,
            },
          },
        },
        ["Implement"] = {
          strategy = "inline",
          description = "Flesh out the selected stub into a full implementation",
          opts = {
            alias = "implement",
            auto_submit = true,
            placement = "replace",
            adapter = { name = "kj_qwen" },
          },
          prompts = {
            {
              role = "system",
              content = function(context)
                local c = conventions_for(context.filetype)
                return string.format([[
You are implementing a function in a %s codebase.
Given a function stub (signature + docstring), produce the complete implementation.

Requirements:
- Preserve the existing signature exactly.
- Copy the existing docstring verbatim, character-for-character. Do not reword, reflow, or add sections.
- Follow %s idioms. %s
- Handle edge cases implied by the docstring.
- Do NOT add imports at the top of the file; assume the surrounding file handles them. If a stdlib import is strictly required, add it inline inside the function.

The user prompt includes a <file_context> block showing the rest of the file (the stub itself is replaced by a placeholder). Use it to call existing helpers/methods, match style, and respect types defined elsewhere. Do NOT copy code from <file_context> — only produce the implementation of the stub.

Output rules:
- Return ONLY the complete function definition.
- No markdown code fences.
- No surrounding prose or explanation.
]], c.name, c.name, c.extra)
              end,
            },
            {
              role = "user",
              content = function(context)
                local code = (context.lines and #context.lines > 0) and table.concat(context.lines, "\n") or ""
                local file_ctx = buffer_minus_selection(context)
                return string.format(
                  "Language: %s\nFile: %s\n\n<file_context>\n%s\n</file_context>\n\nImplement this stub:\n\n%s",
                  context.filetype,
                  context.filename or "",
                  file_ctx,
                  code
                )
              end,
              opts = { contains_code = true },
            },
          },
        },
      },
    },
    config = function(_, opts)
      require("codecompanion").setup(opts)

      -- Run a codecompanion inline command with display.diff.enabled = false,
      -- restoring the flag once the response has been processed. The diff
      -- decision is queued via vim.schedule inside Inline:done, so deferring
      -- the restore via vim.schedule from CodeCompanionRequestFinished places
      -- it after the diff check in the FIFO queue.
      local function without_diff(cmd)
        local cc_config = require("codecompanion.config")
        local prev = cc_config.display.diff.enabled
        cc_config.display.diff.enabled = false
        vim.api.nvim_create_autocmd("User", {
          pattern = "CodeCompanionRequestFinished",
          once = true,
          callback = function()
            vim.schedule(function()
              cc_config.display.diff.enabled = prev
            end)
          end,
        })
        vim.cmd(cmd)
      end

      vim.api.nvim_create_user_command("Stub", function(args)
        if #vim.trim(args.args or "") == 0 then
          vim.notify("Usage: :Stub <description>", vim.log.levels.WARN)
          return
        end
        without_diff("CodeCompanion /stub " .. args.args)
      end, { nargs = "+", desc = "Generate a function stub with kj-qwen" })

      vim.api.nvim_create_user_command("Implement", function(args)
        if args.range == 0 then
          vim.notify("Usage: select a stub in visual mode, then :'<,'>Implement", vim.log.levels.WARN)
          return
        end
        without_diff(args.line1 .. "," .. args.line2 .. "CodeCompanion /implement")
      end, { range = true, desc = "Implement the selected stub with kj-qwen" })
    end,
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
