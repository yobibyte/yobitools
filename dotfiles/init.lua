vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.wo.number = true
vim.wo.signcolumn = 'yes'
vim.o.mouse = 'i'
vim.o.clipboard = 'unnamedplus'
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.timeoutlen = 300
vim.o.completeopt = 'menuone,noselect'
vim.o.termguicolors = true
vim.o.autoread = true
vim.o.foldlevel = 99
vim.o.foldlevelstart = 4
vim.o.foldnestmax = 4
vim.cmd 'syntax off'
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then vim.fn.system {'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath,} end
vim.opt.rtp:prepend(lazypath)
require('lazy').setup({
  'yobibyte/vim-fugitive', 'yobibyte/vim-sleuth', 'yobibyte/undotree', 'yobibyte/Comment.nvim', 'yobibyte/helix-nvim',
  {"yobibyte/harpoon",branch = "harpoon2",dependencies = { "yobibyte/plenary.nvim" }},
  {'yobibyte/telescope.nvim', defaults={file_ignore_patterns={".venv.",},}, branch = '0.1.x', dependencies = { 'yobibyte/plenary.nvim',
  {'yobibyte/telescope-fzf-native.nvim', build = 'make', cond = function() return vim.fn.executable 'make' == 1 end,},},},
  {'yobibyte/nvim-treesitter', dependencies = {'yobibyte/nvim-treesitter-textobjects',},build = ':TSUpdate',},
  {"yobibyte/neogen", dependencies = "yobibyte/nvim-treesitter", config = true, languages = { python = { template = { annotation_convention = "google_docstrings" } } },}}, {})
require('telescope').setup()
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    ensure_installed = { 'latex', 'c', 'cpp', 'python', 'rust', 'bash', 'zig' }, ignore_install = {'javascript', 'vim'},
    auto_install = false, sync_install = false, modules = {}, highlight = { enable = false }, indent = { enable = true },
    incremental_selection = { enable = true,
      keymaps = {init_selection = '<c-space>', node_incremental = '<c-space>', scope_incremental = '<c-s>', node_decremental = '<M-space>',},},
    textobjects = {
      select = { enable = true, lookahead = true,
        keymaps = {['aa'] = '@parameter.outer', ['ia'] = '@parameter.inner', ['af'] = '@function.outer',
                   ['if'] = '@function.inner',  ['ac'] = '@class.outer',     ['ic'] = '@class.inner',},},
      move = { enable = true, set_jumps = true, goto_next_start = {    [']m'] = '@function.outer',[']]'] = '@class.outer',},
        goto_previous_start = {['[m'] = '@function.outer',['[['] = '@class.outer',},},},}
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "FileType" }, {
      callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        if pcall(vim.treesitter.get_parser, bufnr) then
          vim.wo.foldmethod = "expr"
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        end
      end,
    })
  end, 0
)
local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>?',       builtin.oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', builtin.buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/',       builtin.current_buffer_fuzzy_find, {})
vim.keymap.set('n', '<leader>sf',      builtin.find_files, {})
vim.keymap.set('n', '<leader>sg',      builtin.live_grep, {})
vim.keymap.set('n', '<leader>sr',      builtin.resume, {})
vim.keymap.set('n', "<leader>t", vim.cmd.Ex)
vim.keymap.set('n', "<leader>k", vim.cmd.UndotreeToggle)
vim.keymap.set('n', '<leader>jg', ':vertical Git<CR>', {})
vim.keymap.set('n', '<leader>n', ':bn<CR>', {})
vim.keymap.set('n', '<leader>p', ':bp<CR>', {})
vim.keymap.set("n", "<leader>q", ":bd<CR>", {})
vim.keymap.set("n", "<leader>cc", ":lua require('neogen').generate()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-j>", ":move .+1<CR>", {})
vim.keymap.set("n", "<C-k>", ":move .-2<CR>", {})
vim.keymap.set('v', '<C-j>', ":move '>+1<CR>gv", { noremap = true, silent = true })
vim.keymap.set('v', '<C-k>', ":move '<-2<CR>gv", { noremap = true, silent = true })
vim.keymap.set("i", "jj", "<Esc>")
vim.keymap.set("i", ";;", "<Esc>:w<CR>")
vim.keymap.set("n", ";;", ":w<CR>")
local harpoon = require("harpoon") harpoon:setup()
vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
for i=1,9 do vim.keymap.set("n", string.format("<leader>%d", i), function() harpoon:list():select(i) end) end
vim.keymap.set("n", "<C-h>", function() harpoon:list():prev() end)
vim.keymap.set("n", "<C-l>", function() harpoon:list():next() end)
vim.api.nvim_create_user_command("PySources", function()
  vim.cmd("edit " .. vim.fn.system("python3 -c 'import site; print(site.getsitepackages()[0])'"):gsub("%s+$", "") .. "/.")
end, {})
vim.api.nvim_create_user_command("RustSources", function()
  local registry = os.getenv("CARGO_HOME") or (os.getenv("HOME") .. "/.cargo") .. "/registry/src"
  local dir = vim.fn.systemlist("ls -1 " .. registry)[1]
  vim.cmd("edit " .. registry .. "/" .. dir .. "/.")
end, {})
vim.api.nvim_create_user_command("SearchDocs", function() local cwd = vim.fn.expand('%:p:h') require('telescope.builtin').grep_string({search = '',cwd = cwd,}) end, {})
vim.api.nvim_create_user_command("SearchDocFiles", function() local cwd = vim.fn.expand('%:p:h') require('telescope.builtin').find_files({cwd = cwd,}) end, {})
vim.api.nvim_set_keymap('n', '<leader>gp', ':PySources<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gr', ':RustSources<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ds', ':SearchDocs<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>df', ':SearchDocFiles<CR>', { noremap = true, silent = true })
vim.api.nvim_create_autocmd('TextYankPost', {callback = function() vim.highlight.on_yank() end, group = vim.api.nvim_create_augroup('YankHighlight', {clear = true }), pattern = '*',})
vim.cmd 'colorscheme helix'
