local map = vim.keymap.set

-- LocalLeader escape
map("n", "<LocalLeader><LocalLeader>", ",", { desc = "Literal comma" })

-- Toggle cursorline
map("n", "<LocalLeader>v", "<cmd>set cursorline!<CR>", { desc = "Toggle cursorline" })

-- Window navigation
map("n", "<C-J>", "<C-W><C-J>", { desc = "Window down" })
map("n", "<C-K>", "<C-W><C-K>", { desc = "Window up" })
map("n", "<C-L>", "<C-W><C-L>", { desc = "Window right" })
map("n", "<C-H>", "<C-W><C-H>", { desc = "Window left" })

-- Buffer navigation
map("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })

-- Terminal mode
map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- Auto-close brackets/quotes
map("i", "(", "()<C-g>U<Left>")
map("i", "[", "[]<C-g>U<Left>")
map("i", "{", "{}<C-g>U<Left>")
map("i", '"', function()
  if vim.fn.strpart(vim.fn.getline("."), vim.fn.col(".") - 1, 1) == '"' then
    return "<Right>"
  else
    return '""<C-g>U<Left>'
  end
end, { expr = true })
map("i", ")", function()
  return vim.fn.getline("."):sub(vim.fn.col("."), vim.fn.col(".")) == ")" and "<C-g>U<Right>" or ")"
end, { expr = true })
map("i", "]", function()
  return vim.fn.getline("."):sub(vim.fn.col("."), vim.fn.col(".")) == "]" and "<C-g>U<Right>" or "]"
end, { expr = true })
map("i", "}", function()
  return vim.fn.getline("."):sub(vim.fn.col("."), vim.fn.col(".")) == "}" and "<C-g>U<Right>" or "}"
end, { expr = true })

-- Backspace deletes matching pairs
map("i", "<BS>", function()
  local pairs = { ["{}"] = true, ["[]"] = true, ["()"] = true, ['""'] = true, ["''"] = true }
  local line = vim.fn.getline(".")
  local col = vim.fn.col(".")
  local two = line:sub(col - 1, col)
  if pairs[two] then
    return "<C-g>U<Right><BS><BS>"
  else
    return "<BS>"
  end
end, { expr = true })
