vim.g.mapleader = ' '
vim.wo.number = true
vim.g.maplocalleader = ' '
vim.o.hlsearch = false
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
vim.o.autoread = true

-- Setup folding.
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 4
vim.o.foldnestmax = 4
-- zf/string creates a fold from the cursor to string .
-- zj moves the cursor to the next fold.
-- zk moves the cursor to the previous fold.
-- zo opens a fold at the cursor.
-- zO opens all folds at the cursor.
-- zm increases the foldlevel by one.
-- zM closes all open folds.
-- zr decreases the foldlevel by one.
-- zR decreases the foldlevel to zero -- all folds will be open.
-- zd deletes the fold at the cursor.
-- zE deletes all folds.
-- [z move to start of open fold.
-- ]z move to end of open fold.

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath,} 
end
vim.opt.rtp:prepend(lazypath)

-- I created forks of all the plugins I use to pin the versions and update when I want.
require('lazy').setup({
  'yobibyte/vim-fugitive',
  'yobibyte/vim-sleuth', 
  'yobibyte/undotree', 
  'yobibyte/Comment.nvim',
  'yobibyte/helix-nvim',
  { "EdenEast/nightfox.nvim" },
  -- I want to try this out.
  -- {
  --   'projekt0n/github-nvim-theme',
  --   name = 'github-theme',
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     require('github-theme').setup({
  --       -- ...
  --     })
  --     vim.cmd('colorscheme github_light_high_contrast')
  --   end,
  -- },
  'yobibyte/nvim-treesitter-context',
  {'yobibyte/rustaceanvim',version = '^5',lazy = false, ft="rust"},
  {'yobibyte/nvim-dap', 
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dap.listeners.before.attach.dapui_config = function() dapui.open() end
      dap.listeners.before.launch.dapui_config = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
      dap.listeners.before.event_exited.dapui_config = function() dapui.close() end
    end
  },
  {"yobibyte/nvim-dap-ui", dependencies = {"yobibyte/nvim-dap", "yobibyte/nvim-nio"}, config = function() require("dapui").setup() end,},
  {'yobibyte/aerial.nvim',opts = {},dependencies = {"yobibyte/nvim-treesitter",},},
  {'yobibyte/nvim-lspconfig', dependencies = {'yobibyte/mason.nvim', 'yobibyte/mason-lspconfig.nvim', {'yobibyte/fidget.nvim', opts = {} },},},
  {'yobibyte/nvim-cmp',dependencies = {'yobibyte/LuaSnip','yobibyte/cmp_luasnip','yobibyte/cmp-nvim-lsp',},},
  {'yobibyte/gitsigns.nvim', opts = {signs = {add = { text = '+' }, change = { text = '~' }, changedelete = { text = '~' },},},},
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
  local nmap = function(keys, func, desc) vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc }) end
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-h>', vim.lsp.buf.signature_help, 'Signature Documentation')
  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gvd', function() vim.cmd('vsplit') vim.cmd('wincmd l') require('telescope.builtin').lsp_definitions() end, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
end
require('mason').setup() require('mason-lspconfig').setup()
local servers = {texlab = {}, pyright = {}, ruff = {}, html = {}, zls = {}}
local capabilities = vim.lsp.protocol.make_client_capabilities() capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
local mason_lspconfig = require 'mason-lspconfig'
mason_lspconfig.setup {ensure_installed = vim.tbl_keys(servers),}
mason_lspconfig.setup_handlers {function(server_name) require('lspconfig')[server_name].setup {
  capabilities = capabilities, on_attach = on_attach, settings = servers[server_name], filetypes = (servers[server_name] or {}).filetypes, } end,}
    
-- Rustacean does not use lspconfig to setup. Do it yourself.
local mason_registry = require('mason-registry')
local codelldb = mason_registry.get_package('codelldb')
local extension_path = codelldb:get_install_path() .. "/extension/"
local codelldb_path = extension_path .. "adapter/codelldb"
local liblldb_path = extension_path .. "lldb/lib/liblldb.so"
vim.g.rustaceanvim = {
  tools = {},
  server = {on_attach = on_attach,},
  default_settings = {['rust-analyzer'] = {},},
  dap = {adapter = require('rustaceanvim.config').get_codelldb_adapter(codelldb_path, liblldb_path)},
}

-- Setup completion
local cmp = require 'cmp' local luasnip = require 'luasnip'
luasnip.config.setup {}
cmp.setup { snippet = {expand = function(args) luasnip.lsp_expand(args.body) end,},
  completion = {completeopt = 'menu,menuone,noinsert'},
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(), ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<CR>'] = cmp.mapping.confirm {behavior = cmp.ConfirmBehavior.Replace,select = true,},},
  sources = {{ name = 'nvim_lsp' },{ name = 'luasnip' },},}

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {callback = function() vim.highlight.on_yank() end, group = vim.api.nvim_create_augroup('YankHighlight', {clear = true }), pattern = '*',})

-- Setup the rest of shortcuts.
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

-- Nvim DAP
vim.keymap.set("n", "<Leader>dl", "<cmd>lua require'dap'.step_into()<CR>", { desc = "Debugger step into" })
vim.keymap.set("n", "<Leader>dj", "<cmd>lua require'dap'.step_over()<CR>", { desc = "Debugger step over" })
vim.keymap.set("n", "<Leader>dk", "<cmd>lua require'dap'.step_out()<CR>", { desc = "Debugger step out" })
vim.keymap.set("n", "<Leader>dc", "<cmd>lua require'dap'.continue()<CR>", { desc = "Debugger continue" })
vim.keymap.set("n", "<Leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<CR>", { desc = "Debugger toggle breakpoint" })
vim.keymap.set("n", "<Leader>de", "<cmd>lua require'dap'.terminate()<CR>", { desc = "Debugger reset" })
vim.keymap.set("n", "<Leader>dr", "<cmd>lua require'dap'.run_last()<CR>", { desc = "Debugger run last" })

-- rustaceanvim
vim.keymap.set("n", "<Leader>dt", "<cmd>lua vim.cmd('RustLsp testables')<CR>", { desc = "Debugger testables" })

-- vim.cmd 'colorscheme helix'
vim.cmd 'colorscheme dayfox'

-- Turn off annoying zls window with diagnostics.
vim.g.zig_fmt_parse_errors = 0
-- Fmt on save for Rust.
vim.g.rustfmt_autosave = 1

-- TODO: automate codelldb install
-- Right now we use :MasonInstall codelldb
