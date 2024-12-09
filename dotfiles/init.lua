vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.o.hlsearch = false
vim.wo.number = true
vim.o.mouse = 'i'
vim.o.clipboard = 'unnamedplus'
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.wo.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.completeopt = 'menuone,noselect'
vim.o.termguicolors = true
vim.wo.relativenumber = true
vim.o.autoread = true -- update buffers if files were changed outside

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath,} 
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  'tpope/vim-fugitive',
  'tpope/vim-sleuth',
  'mbbill/undotree',
  {'stevearc/aerial.nvim',opts = {},dependencies = {"nvim-treesitter/nvim-treesitter",},},
  {'neovim/nvim-lspconfig', dependencies = {'williamboman/mason.nvim', 'williamboman/mason-lspconfig.nvim', {'j-hui/fidget.nvim', opts = {} },},},
  {'hrsh7th/nvim-cmp',dependencies = {'L3MON4D3/LuaSnip','saadparwaiz1/cmp_luasnip','hrsh7th/cmp-nvim-lsp',},},
  {'lewis6991/gitsigns.nvim', opts = {signs = {add = { text = '+' }, change = { text = '~' }, changedelete = { text = '~' },},},},
  {'numToStr/Comment.nvim', opts = {} },
  {'nvim-telescope/telescope.nvim', defaults={file_ignore_patterns={".venv.",},}, branch = '0.1.x', dependencies = { 'nvim-lua/plenary.nvim',
    {'nvim-telescope/telescope-fzf-native.nvim', build = 'make', cond = function() return vim.fn.executable 'make' == 1 end,},},},
  {'nvim-treesitter/nvim-treesitter', dependencies = {'nvim-treesitter/nvim-treesitter-textobjects',},build = ':TSUpdate',},
  {"danymat/neogen", dependencies = "nvim-treesitter/nvim-treesitter", config = true, languages = { python = { template = { annotation_convention = "google_docstrings" } } },}}, {}
)

vim.api.nvim_create_autocmd('TextYankPost', {callback = function() vim.highlight.on_yank() end, group = vim.api.nvim_create_augroup('YankHighlight', {clear = true }), pattern = '*',})
require('telescope').setup()
pcall(require('telescope').load_extension, 'fzf') pcall(require('telescope').load_extension, 'aerial')

vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', require('telescope.builtin').current_buffer_fuzzy_find, {})
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, {})
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, {})
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, {})
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, {})
vim.keymap.set('n', '<leader>ss', ':Telescope aerial<cr>', {})
vim.keymap.set('n', "<leader>t", vim.cmd.Ex)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', "<leader>k", vim.cmd.UndotreeToggle)
vim.keymap.set('n', '<leader>nr', ':set number relativenumber<cr>', {})
vim.keymap.set('n', '<leader>na', ':set number norelativenumber<cr>', {})
vim.keymap.set('n', '<leader>gj', ':vertical Git<CR>', {})
vim.api.nvim_set_keymap("n", "<Leader>cc", ":lua require('neogen').generate()<CR>", { noremap = true, silent = true })

vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    ensure_installed = { 'latex', 'c', 'cpp', 'python', 'rust', 'bash' }, ignore_install = {'javascript', 'vim'},
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

local on_attach = function(_, bufnr)
  local nmap = function(keys, func, desc) vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc }) end
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
end

require('mason').setup() require('mason-lspconfig').setup()
local servers = {texlab = {}, pyright = {}, ruff = {}, html = {}, rust_analyzer = {},}
local capabilities = vim.lsp.protocol.make_client_capabilities() capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
local mason_lspconfig = require 'mason-lspconfig'
mason_lspconfig.setup {ensure_installed = vim.tbl_keys(servers),}
mason_lspconfig.setup_handlers {function(server_name) require('lspconfig')[server_name].setup {
  capabilities = capabilities, on_attach = on_attach, settings = servers[server_name], filetypes = (servers[server_name] or {}).filetypes, } end,}

local cmp = require 'cmp' local luasnip = require 'luasnip'
luasnip.config.setup {}
cmp.setup { snippet = {expand = function(args) luasnip.lsp_expand(args.body) end,},
  completion = {completeopt = 'menu,menuone,noinsert'},
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(), ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<CR>'] = cmp.mapping.confirm {behavior = cmp.ConfirmBehavior.Replace,select = true,},},
  sources = {{ name = 'nvim_lsp' },{ name = 'luasnip' },},}

vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {command = "if mode() != 'c' | checktime | endif", pattern = { "*" },})
vim.cmd 'colorscheme retrobox'
