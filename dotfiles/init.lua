vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.wo.number = true
vim.wo.signcolumn = 'yes'
vim.wo.relativenumber = true
vim.o.hlsearch = false
vim.o.mouse = 'i'
vim.o.clipboard = 'unnamedplus'
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.completeopt = 'menuone,noselect'
vim.o.termguicolors = true
vim.o.autoread = true

-- zf/string creates a fold from the cursor to string .
-- zj/zk moves the cursor to the next/previous fold.
-- zo/zO opens a fold/all folds at the cursor.
-- zm/zr increases/decreases the foldlevel by one.
-- zM/zR closes all open folds/opens all folds
-- [z/]z move to start/end of open fold.
vim.o.foldmethod = "expr"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 4
vim.o.foldnestmax = 4

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath,} 
end
vim.opt.rtp:prepend(lazypath)
require('lazy').setup({
  'yobibyte/vim-fugitive',
  'yobibyte/vim-sleuth', 
  'yobibyte/undotree', 
  'yobibyte/Comment.nvim',
  'yobibyte/helix-nvim',
  {"yobibyte/harpoon",branch = "harpoon2",dependencies = { "yobibyte/plenary.nvim" }},
  'yobibyte/nvim-treesitter-context',
  {'yobibyte/aerial.nvim',opts = {},dependencies = {"yobibyte/nvim-treesitter",},},
  {'yobibyte/nvim-lspconfig', dependencies = {'yobibyte/mason.nvim', 'yobibyte/mason-lspconfig.nvim', {'yobibyte/fidget.nvim', opts = {} },},},
  {'yobibyte/nvim-cmp',dependencies = {'yobibyte/LuaSnip','yobibyte/cmp_luasnip','yobibyte/cmp-nvim-lsp',},},
  {'yobibyte/gitsigns.nvim', opts={signs={add ={text='+'},change={text='~'},changedelete={text='~'},},},},
  {'yobibyte/telescope.nvim', defaults={file_ignore_patterns={".venv.",},}, branch = '0.1.x', dependencies = { 'yobibyte/plenary.nvim',
  {'yobibyte/telescope-fzf-native.nvim', build = 'make', cond = function() return vim.fn.executable 'make' == 1 end,},},},
  {'yobibyte/nvim-treesitter', dependencies = {'yobibyte/nvim-treesitter-textobjects',},build = ':TSUpdate',},
  {"yobibyte/neogen", dependencies = "yobibyte/nvim-treesitter", config = true, languages = { python = { template = { annotation_convention = "google_docstrings" } } },}}, {}
)
require('telescope').setup()
pcall(require('telescope').load_extension, 'fzf') pcall(require('telescope').load_extension, 'aerial')
-- Setup treesitter.
vim.defer_fn(function()
  vim.keymap.set("n", "[c", function()
    require("treesitter-context").go_to_context(vim.v.count1)
  end, { silent = true })
  require('nvim-treesitter.configs').setup {
    ensure_installed = { 'latex', 'c', 'cpp', 'python', 'rust', 'bash', 'zig' }, ignore_install = {'javascript', 'vim'},
    auto_install = false, sync_install = false, modules = {}, highlight = { enable = true }, indent = { enable = true },
    incremental_selection = { enable = true,
      keymaps = {init_selection = '<c-space>', node_incremental = '<c-space>', scope_incremental = '<c-s>', node_decremental = '<M-space>',},},
    textobjects = {
      select = { enable = true, lookahead = true,
        keymaps = {['aa'] = '@parameter.outer', ['ia'] = '@parameter.inner', ['af'] = '@function.outer',
                   ['if'] = '@function.inner',  ['ac'] = '@class.outer',     ['ic'] = '@class.inner',},},
      move = { enable = true, set_jumps = true, goto_next_start = {    [']m'] = '@function.outer',[']]'] = '@class.outer',},
        goto_previous_start = {['[m'] = '@function.outer',['[['] = '@class.outer',},},},} end, 0
)
-- Setup lsp servers.
local on_attach = function(_, bufnr)
  vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  local nmap = function(keys, func, desc) vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc }) end
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gvd', function() vim.cmd('vsplit') vim.cmd('wincmd l') require('telescope.builtin').lsp_definitions() end, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
end
require('mason').setup() require('mason-lspconfig').setup()
local servers = {texlab = {}, pyright = {}, ruff = {}, html = {}, zls = {}, rust_analyzer = {}}
local capabilities = vim.lsp.protocol.make_client_capabilities() capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
local mason_lspconfig = require 'mason-lspconfig'
mason_lspconfig.setup {ensure_installed = vim.tbl_keys(servers),}
mason_lspconfig.setup_handlers {function(server_name) require('lspconfig')[server_name].setup {
  capabilities = capabilities, on_attach = on_attach, settings = servers[server_name], filetypes = (servers[server_name] or {}).filetypes, } end,}
-- Setup completion
local cmp = require 'cmp' local luasnip = require 'luasnip' luasnip.config.setup {}
cmp.setup { snippet = {expand = function(args) luasnip.lsp_expand(args.body) end,},
  completion = {completeopt = 'menu,menuone,noinsert'},
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(), ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<CR>'] = cmp.mapping.confirm {behavior = cmp.ConfirmBehavior.Replace,select = true,},},
  sources = {{ name = 'nvim_lsp' },{ name = 'luasnip' },},}

local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>?',       builtin.oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', builtin.buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/',       builtin.current_buffer_fuzzy_find, {})
vim.keymap.set('n', '<leader>sf',      builtin.find_files, {})
vim.keymap.set('n', '<leader>sg',      builtin.live_grep, {})
vim.keymap.set('n', '<leader>sd',      builtin.diagnostics, {})
vim.keymap.set('n', '<leader>sr',      builtin.resume, {})
vim.keymap.set('n', '<leader>ss', ':Telescope aerial<cr>', {})
vim.keymap.set('n', "<leader>t", vim.cmd.Ex)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', "<leader>k", vim.cmd.UndotreeToggle)
vim.keymap.set('n', '<leader>nr', ':set number relativenumber<cr>', {})
vim.keymap.set('n', '<leader>na', ':set number norelativenumber<cr>', {})
vim.keymap.set('n', '<leader>jg', ':vertical Git<CR>', {})
vim.keymap.set('n', '<leader>n', ':bn<CR>', {})
vim.keymap.set('n', '<leader>p', ':bp<CR>', {})
vim.keymap.set("n", "<leader>b", ":Cargo build<CR>", {})
vim.keymap.set("n", "<leader>q", ":bd<CR>", {})
vim.keymap.set("n", "<leader>cc", ":lua require('neogen').generate()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-j>", ":move .+1<CR>", {})
vim.keymap.set("n", "<C-k>", ":move .-2<CR>", {})
vim.keymap.set('v', '<C-j>', ":move '>+1<CR>gv", { noremap = true, silent = true })
vim.keymap.set('v', '<C-k>', ":move '<-2<CR>gv", { noremap = true, silent = true })

vim.cmd 'colorscheme helix'
vim.g.zig_fmt_parse_errors = 0
vim.g.rustfmt_autosave = 1
vim.api.nvim_create_autocmd('TextYankPost', {callback = function() vim.highlight.on_yank() end, group = vim.api.nvim_create_augroup('YankHighlight', {clear = true }), pattern = '*',})

local harpoon = require("harpoon")
harpoon:setup()
vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
for i=1,9 do
  vim.keymap.set("n", string.format("<leader>%d", i), function() harpoon:list():select(i) end)
end
vim.keymap.set("n", "<C-h>", function() harpoon:list():prev() end)
vim.keymap.set("n", "<C-l>", function() harpoon:list():next() end)
vim.keymap.set("i", "jj", "<Esc>")
vim.keymap.set("i", ";;", "<Esc>:w<CR>")
vim.keymap.set("n", ";;", ":w<CR>")
