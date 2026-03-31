return {
  -- Distraction-free writing
  {
    "junegunn/goyo.vim",
    cmd = "Goyo",
    init = function()
      vim.g.goyo_linenr = 0
      vim.g.goyo_width = 90
    end,
    config = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "GoyoEnter",
        callback = function()
          vim.opt_local.eventignore = "FocusGained"
          vim.b.quitting = 0
          vim.b.quitting_bang = 0
          vim.api.nvim_create_autocmd("QuitPre", {
            buffer = 0,
            callback = function() vim.b.quitting = 1 end,
          })
          vim.cmd([[cabbrev <buffer> q! let b:quitting_bang = 1 <bar> q!]])
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "GoyoLeave",
        callback = function()
          vim.opt_local.eventignore = ""
          if vim.b.quitting == 1 then
            local bufs = vim.tbl_filter(
              function(b) return vim.fn.buflisted(b) == 1 end,
              vim.fn.range(1, vim.fn.bufnr("$"))
            )
            if #bufs == 1 then
              if vim.b.quitting_bang == 1 then
                vim.cmd("qa!")
              else
                vim.cmd("qa")
              end
            end
          end
        end,
      })
    end,
  },
}
