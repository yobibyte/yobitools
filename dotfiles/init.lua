vim.o.undofile = true
vim.opt.expandtab = true
vim.o.clipboard = "unnamedplus"
vim.opt.shiftwidth = 4
vim.opt.softtabstop = -1
vim.o.laststatus = 0
vim.cmd("syntax off | highlight Normal guibg=#282828 guifg=#d78700")
vim.api.nvim_create_autocmd("BufEnter", {callback = function() vim.treesitter.stop() end})
