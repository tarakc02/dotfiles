local autocmd = vim.api.nvim_create_autocmd

-- Dim inactive windows
autocmd("WinEnter", {
  callback = function() vim.wo.cursorline = true end,
})
autocmd("WinLeave", {
  callback = function() vim.wo.cursorline = false end,
})

-- Terminal settings
autocmd("TermOpen", {
  callback = function()
    vim.bo.buflisted = false
    vim.wo.foldcolumn = "0"
  end,
})
