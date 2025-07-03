vim.o.undofile      = true
vim.o.clipboard     = "unnamedplus"
vim.opt.expandtab   = true
vim.opt.shiftwidth  = 4
vim.opt.softtabstop = -1
vim.cmd("syntax off | colorscheme retrobox | highlight Normal guifg=#ffaf00 guibg=#282828")
vim.api.nvim_create_autocmd("TextYankPost", { callback = function() vim.highlight.on_yank() end})
vim.api.nvim_create_autocmd("BufEnter",     { callback = function() vim.treesitter.stop() end})
vim.opt.grepprg = "rg --vimgrep --no-ignore-parent --glob='!wandb/**' -- $*"
vim.keymap.set("n", "<space>l", ":ls<cr>:b ")
vim.keymap.set('n', '<space>y', function() vim.fn.setreg('+', vim.fn.expand('%:p')) end)
vim.keymap.set("n", "<space>c", function() vim.ui.input({}, function(c) if c then 
  vim.cmd("vnew") vim.bo.buftype = "nofile" vim.bo.bufhidden = "wipe" vim.bo.swapfile = false
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.fn.systemlist(c)) end end) end)
