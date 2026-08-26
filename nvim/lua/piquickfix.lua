-- piquickfix.lua — apply quickfix entries pushed by the pi codecompanion agent.
--
-- While pi runs as the codecompanion chat agent, its `quickfix` tool appends
-- JSON lines to a per-project mailbox file:
--
--     <git-root>/.sandbox-home/cc-quickfix.jsonl
--
-- (path overridable with the CC_QF_FILE env var). This module tails that file
-- and applies each line to the quickfix list with setqflist(). A file mailbox
-- is used instead of nvim RPC so the sandboxed pi needs no socket, no
-- msgpack client and no extra mounts: the project dir is rw inside the
-- sandbox and host-visible at the same path.
--
-- Line schema (one JSON object per line, complete snapshot per action):
--   { "ts":<ms>, "action":"set"|"append", "title":"...",
--     "entries":[{ file, line?, col?, text?, type? }] }
--   set    -> replace the accumulated list
--   append -> add to the accumulated list
--
-- Lifecycle: call M.start(cwd) when a codecompanion chat opens (the pi
-- adapter), M.stop() when it closes. M.apply() forces a re-read + apply.
-- User commands: :PiQuickfix (apply + open), :PiQuickfixApply, :PiQuickfixStatus.

local M = {}

local state = {
  file = nil,       -- absolute path of the mailbox being watched
  root = nil,       -- git root the mailbox lives in (for absolutizing paths)
  timer = nil,
  applied = 0,      -- index of the last JSONL line applied
  last_key = nil,   -- "mtime:size" observed at last scan
  entries = {},     -- accumulated quickfix entries
  title = "pi",
  last_action = nil,
  auto_open = true, -- open the quickfix window on a "set" (fresh list)
}

local POLL_MS = 800

local function log(msg)
  vim.notify("[piquickfix] " .. msg, vim.log.levels.DEBUG)
end

---Default mailbox for a cwd, mirroring the extension's rule.
local function default_mailbox(root)
  return root .. "/.sandbox-home/cc-quickfix.jsonl"
end

---Resolve the git root for a cwd (fallback: the cwd itself).
local function git_root(cwd)
  local out = vim.fn.system({ "git", "-C", cwd, "rev-parse", "--show-toplevel" })
  if vim.v.shell_error == 0 then
    local root = vim.trim(out)
    if root ~= "" then
      return root
    end
  end
  return cwd
end

---Turn one mailbox entry into a setqflist item with an absolute filename.
local function to_qf(entry)
  local file = entry.file or ""
  if file:sub(1, 1) ~= "/" then
    file = state.root .. "/" .. file
  end
  local q = {
    filename = file,
    text = (entry.text ~= nil and entry.text ~= "") and entry.text or file,
  }
  if entry.type then
    q.type = tostring(entry.type):sub(1, 1) -- E/W/I/N
  end
  if type(entry.line) == "number" and entry.line > 0 then
    q.lnum = entry.line
    if type(entry.col) == "number" and entry.col > 0 then
      q.col = entry.col
    end
  end
  return q
end

---Parse one JSONL line; returns nil on malformed/partial lines.
local function parse_line(line)
  if type(line) ~= "string" or vim.trim(line) == "" then
    return nil
  end
  local ok, data = pcall(vim.json.decode, line)
  if not ok or type(data) ~= "table" then
    return nil
  end
  local action = data.action
  if action ~= "set" and action ~= "append" then
    action = "set"
  end
  if type(data.entries) ~= "table" then
    return nil
  end
  return {
    action = action,
    title = (type(data.title) == "string" and data.title ~= "") and data.title or nil,
    entries = data.entries,
  }
end

---Re-read the mailbox and apply any lines not yet applied. Returns the number
---of entries currently in the accumulated list, or nil when nothing to do.
function M.apply()
  if not state.file then
    return nil
  end
  local fd = io.open(state.file, "r")
  if not fd then
    return nil
  end
  local lines = {}
  for line in fd:lines() do
    lines[#lines + 1] = line
  end
  fd:close()

  -- File truncated (rewritten from scratch): rebuild from line 1.
  if #lines < state.applied then
    state.applied = 0
    state.entries = {}
  end

  local changed = false
  for i = state.applied + 1, #lines do
    local parsed = parse_line(lines[i])
    if parsed then
      if parsed.action == "set" then
        state.entries = {}
      end
      for _, e in ipairs(parsed.entries) do
        table.insert(state.entries, to_qf(e))
      end
      if parsed.title then
        state.title = parsed.title
      end
      state.last_action = parsed.action
      state.applied = i
      changed = true
    end
    -- A malformed trailing line is left unapplied and retried on the next scan.
  end

  if changed then
    vim.fn.setqflist(state.entries, " ")
    -- Action "a" (add) with an empty list only applies the {title} field:
    -- using " " here would REPLACE the list we just set with an empty one.
    vim.fn.setqflist({}, "a", { title = state.title })
    -- Reveal the window on a fresh "set" (the explicit hand-off), but don't
    -- steal focus on every append.
    if state.auto_open and state.last_action == "set" then
      vim.schedule(function()
        pcall(vim.cmd, "copen")
      end)
    end
  end

  return #state.entries
end

---One scan tick: cheap stat, re-read only when the file changed.
local function tick()
  if not state.file then
    return
  end
  local mtime = vim.fn.getftime(state.file) -- -1 when missing; seconds resolution
  local size = vim.fn.getfsize(state.file)
  local key = (mtime and tostring(mtime) or "-") .. ":" .. tostring(size)
  if key ~= state.last_key then
    state.last_key = key
    M.apply()
  end
end

---Start watching a mailbox for a chat cwd (git root is resolved). Idempotent.
function M.start(cwd)
  local root = git_root(cwd or vim.fn.getcwd())
  local file = os.getenv("CC_QF_FILE")
  if not file or file == "" then
    file = default_mailbox(root)
  end
  state.file = file
  state.root = root
  state.applied = 0
  state.entries = {}
  state.title = "pi"
  state.last_action = nil
  state.last_key = nil

  if state.timer then
    state.timer:stop()
    state.timer:close()
    state.timer = nil
  end
  state.timer = vim.uv.new_timer()
  state.timer:start(0, POLL_MS, vim.schedule_wrap(tick))

  log("watching " .. file)
  return file
end

---Stop watching. Idempotent.
function M.stop()
  if state.timer then
    state.timer:stop()
    state.timer:close()
    state.timer = nil
  end
  state.file = nil
  state.root = nil
  state.applied = 0
  state.entries = {}
  state.last_key = nil
end

function M.status()
  return {
    file = state.file,
    applied = state.applied,
    entries = #state.entries,
    title = state.title,
  }
end

function M.is_active()
  return state.file ~= nil
end

---Register user commands once (idempotent).
function M.setup()
  if vim.g.__piquickfix_setup then
    return
  end
  vim.g.__piquickfix_setup = true

  vim.api.nvim_create_user_command("PiQuickfix", function()
    local n = M.apply()
    if n then
      pcall(vim.cmd, "copen")
      vim.notify(("[piquickfix] applied: %d entries"):format(n), vim.log.levels.INFO)
    else
      vim.notify(
        M.is_active() and "[piquickfix] no pending quickfix entries" or "[piquickfix] not watching (no codecompanion chat?)",
        vim.log.levels.WARN
      )
    end
  end, { desc = "Apply pending pi quickfix entries and open the quickfix window" })

  vim.api.nvim_create_user_command("PiQuickfixApply", function()
    local n = M.apply()
    vim.notify(
      n and ("[piquickfix] applied: %d entries"):format(n) or "[piquickfix] nothing pending",
      vim.log.levels.INFO
    )
  end, { desc = "Apply pending pi quickfix entries without opening the window" })

  vim.api.nvim_create_user_command("PiQuickfixStatus", function()
    local s = M.status()
    vim.notify(
      ("[piquickfix] file=%s applied_lines=%d entries=%d title=%s"):format(
        vim.inspect(s.file),
        s.applied,
        s.entries,
        vim.inspect(s.title)
      ),
      vim.log.levels.INFO
    )
  end, { desc = "Show piquickfix watcher status" })
end

return M
