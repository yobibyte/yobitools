vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.clipboard = "unnamedplus"
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.timeoutlen = 300
vim.cmd("syntax off") vim.api.nvim_set_hl(0, "Normal", { fg = "#ffaf00" })
vim.api.nvim_create_autocmd("VimEnter", { callback = function() if vim.treesitter and vim.treesitter.stop then vim.treesitter.stop() end end, })
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath, }) end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
  "yobibyte/vim-fugitive", {"yobibyte/neogen", config = true,},
  {'yobibyte/telescope.nvim', branch = '0.1.x', dependencies = { 'yobibyte/plenary.nvim', {'yobibyte/telescope-fzf-native.nvim', build = 'make', cond = function() return vim.fn.executable 'make' == 1 end,},},},
}, {})
vim.api.nvim_create_autocmd("TextYankPost", { callback = function() vim.highlight.on_yank() end, group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }), pattern = "*", })
vim.keymap.set("i", "jj", "<Esc>")
vim.keymap.set("n", "<C-j>",           ":move .+1<CR>", {})
vim.keymap.set("n", "<C-k>",           ":move .-2<CR>", {})
vim.keymap.set('v', '<C-j>',           ":move '>+1<CR>gv", { noremap = true, silent = true })
vim.keymap.set('v', '<C-k>',           ":move '<-2<CR>gv", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>e",       ":Explore<cr>")
vim.keymap.set("n", "<leader>n",       ":set number!<cr>")
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers)
vim.keymap.set('n', '<leader>sf',      require('telescope.builtin').find_files)
vim.keymap.set('n', '<leader>sg',      require('telescope.builtin').live_grep)
vim.keymap.set('n', '<leader>sr',      require('telescope.builtin').resume, {})
vim.keymap.set('n', '<leader>so',      require('telescope.builtin').oldfiles)
vim.keymap.set('n', '<leader>sb',      require('telescope.builtin').current_buffer_fuzzy_find, {})
vim.keymap.set('n', '<leader>sc',      function() local fpath = vim.fn.expand("%:p") if fpath ~= "" then require('telescope.builtin').live_grep({ search_dirs = { fpath } }) end end)
vim.keymap.set('n', '<leader>df',      function() require('telescope.builtin').find_files({cwd = vim.fn.expand('%:p:h'), no_ignore=true}) end, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>ds',      function() require('telescope.builtin').live_grep({cwd = vim.fn.expand('%:p:h'), additional_args = function() return { "--hidden", "--no-ignore" } end}) end, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>cc",      ":lua require('neogen').generate()<CR>", { noremap = true, silent = true })
vim.keymap.set('n', '<leader>g', ':Git<CR>', {})
vim.keymap.set('n', '<leader>jg', ':vertical Git<CR>', {})
vim.keymap.set("n", "<leader>gp", function() vim.cmd( "edit " .. vim.fn.system("python3 -c 'import site; print(site.getsitepackages()[0])'") :gsub("%s+$", "") .. "/.") end )
vim.keymap.set("n", "<leader>gr", function() local registry = os.getenv("CARGO_HOME") or (os.getenv("HOME") .. "/.cargo") .. "/registry/src" vim.cmd("edit " .. registry .. "/" .. vim.fn.systemlist("ls -1 " .. registry)[1]) end)
vim.keymap.set("n", "<leader>bb", ":!black %<cr>")
vim.keymap.set("n", "<leader>br", function() vim.cmd("vnew") vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(vim.fn.system({ "ruff", "check", vim.fn.expand("#") }), "\n")) vim.bo.buftype = "nofile" vim.bo.bufhidden = "wipe" vim.bo.swapfile = false end, {})
vim.keymap.set({ "n", "x" }, "<leader>c", function()
  local cs = vim.bo.commentstring:match("^(.*)%%s")
  if not cs or cs == "" then return end
  local s_row, e_row = vim.fn.line("."), vim.fn.line(".")
  if vim.fn.mode() ~= "n" then
    s_row, e_row = vim.fn.line("v"), vim.fn.line(".")
    if s_row > e_row then s_row, e_row = e_row, s_row end
  end
  local lines = {}
  local all_commented = true
  local prefix = vim.trim(cs)
  for i = s_row, e_row do
    local line = vim.fn.getline(i)
    local uncommented = line:gsub("^" .. vim.pesc(prefix) .. "%s?", "", 1)
    if uncommented == line then all_commented = false end
    table.insert(lines, { i, line, uncommented })
  end
  for _, entry in ipairs(lines) do
    local i, line, uncommented = unpack(entry)
    if all_commented then vim.fn.setline(i, uncommented) else vim.fn.setline(i, prefix .. " " .. line) end
  end
end, {})

vim.api.nvim_create_autocmd("BufReadPost", { callback = function()
    local space_count = 0 local tab_count = 0 local min_indent = nil
    for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, 100, false)) do
      if not line:match("^%s*$") then 
        local indent = line:match("^(%s+)")
        if indent then
          if indent:find("\t") then
            tab_count = tab_count + 1
          else
            space_count = space_count + 1
            local len = #indent
            if not min_indent or len < min_indent then min_indent = len end
          end
        end
      end
    end
    if tab_count > space_count then
      vim.opt_local.expandtab = false
    else
      min_indent = min_indent or 2
      vim.opt_local.expandtab = true
      vim.opt_local.shiftwidth = min_indent
      vim.opt_local.tabstop = min_indent
      vim.opt_local.softtabstop = min_indent
    end
  end,
})
