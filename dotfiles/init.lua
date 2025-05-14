vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.o.clipboard = 'unnamedplus'
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.timeoutlen = 300
vim.o.foldlevel = 99
vim.o.foldlevelstart = 4
vim.o.foldnestmax = 4
vim.cmd 'syntax off'
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then vim.fn.system {'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath,} end
vim.opt.rtp:prepend(lazypath)
require('lazy').setup({'yobibyte/vim-fugitive', 'yobibyte/vim-sleuth', 'yobibyte/undotree', 'yobibyte/Comment.nvim', 'yobibyte/github-monochrome.nvim',
  {"yobibyte/harpoon",branch = "harpoon2",dependencies = { "yobibyte/plenary.nvim" }},
  {'yobibyte/telescope.nvim', branch = '0.1.x', dependencies = { 'yobibyte/plenary.nvim', {'yobibyte/telescope-fzf-native.nvim', build = 'make', cond = function() return vim.fn.executable 'make' == 1 end,},},},
  {'yobibyte/nvim-treesitter', dependencies = {'yobibyte/nvim-treesitter-textobjects',}, build = ':TSUpdate', main='nvim-treesitter.configs', 
    opts = {ensure_installed = { 'c', 'cpp', 'python', 'rust', 'bash', 'zig' }, auto_install = true, sync_install = false, indent = { enable = true },
    incremental_selection = { enable = true, keymaps = {init_selection = '<c-space>', node_incremental = '<c-space>', node_decremental = '<M-space>',},},
    textobjects = { select = { enable = true, lookahead = true, keymaps = {['ia'] = '@parameter.inner', ['af'] = '@function.outer', ['ac'] = '@class.outer',},},
    move = { enable = true, set_jumps = true, goto_next_start = {[']m'] = '@function.outer',[']]'] = '@class.outer',}, goto_previous_start = {['[m'] = '@function.outer',['[['] = '@class.outer',},},},},},
  {"yobibyte/neogen", dependencies = "yobibyte/nvim-treesitter", config = true, languages = { python = { template = { annotation_convention = "google_docstrings" } } },}}, {})
local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>?',       builtin.oldfiles)
vim.keymap.set('n', '<leader><space>', builtin.buffers)
vim.keymap.set('n', '<leader>sf',      builtin.find_files)
vim.keymap.set('n', '<leader>sg',      builtin.live_grep)
vim.keymap.set('n', '<leader>sr',      builtin.resume)
vim.keymap.set("n", "<leader>cc", ":lua require('neogen').generate()<CR>", { noremap = true, silent = true })
vim.keymap.set("i", "jj", "<Esc>")
local harpoon = require("harpoon") harpoon:setup()
vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
for i=1,9 do vim.keymap.set("n", string.format("<leader>%d", i), function() harpoon:list():select(i) end) end
vim.api.nvim_create_user_command("PySources", function() vim.cmd("edit " .. vim.fn.system("python3 -c 'import site; print(site.getsitepackages()[0])'"):gsub("%s+$", "") .. "/.") end, {})
vim.api.nvim_create_user_command("RustSources", function() local registry = os.getenv("CARGO_HOME") or (os.getenv("HOME") .. "/.cargo") .. "/registry/src" vim.cmd("edit " .. registry .. "/" .. vim.fn.systemlist("ls -1 " .. registry)[1]) end, {})
vim.api.nvim_create_autocmd('TextYankPost', {callback = function() vim.highlight.on_yank() end, group = vim.api.nvim_create_augroup('YankHighlight', {clear = true }), pattern = '*',})
vim.keymap.set('n', '<leader>df', function() builtin.find_files({cwd = vim.fn.expand('%:p:h'), no_ignore=true}) end, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>ds', function() builtin.live_grep({cwd = vim.fn.expand('%:p:h'), additional_args = function() return { "--hidden", "--no-ignore" } end}) end, { noremap = true, silent = true })
vim.cmd 'colorscheme github-monochrome-solarized'
vim.wo.foldmethod = "expr"
vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
