vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.clipboard = "unnamedplus"
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.timeoutlen = 300
vim.o.foldlevelstart = 99
vim.g.netrw_banner = 0
vim.opt.path:append("**")
vim.cmd("syntax off")
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath, })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
  "yobibyte/vim-fugitive", "yobibyte/vim-sleuth", "yobibyte/Comment.nvim",
  { "yobibyte/harpoon", branch = "harpoon2", dependencies = { "yobibyte/plenary.nvim" }, },
  { "yobibyte/nvim-treesitter",
    dependencies = { "yobibyte/nvim-treesitter-textobjects" },
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = { "c", "cpp", "python", "rust", "bash", "zig" },
      auto_install = true,
      sync_install = false,
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {init_selection = "<c-space>", node_incremental = "<c-space>", node_decremental = "<M-space>",},
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = { ["ia"] = "@parameter.inner", ["af"] = "@function.outer", ["ac"] = "@class.outer", },},
      },
    },
  },
  { "yobibyte/neogen", dependencies = "yobibyte/nvim-treesitter", config = true, languages = { python = { template = { annotation_convention = "google_docstrings" } }, }, },
}, {})
local harpoon = require("harpoon") harpoon:setup()
vim.api.nvim_create_user_command("PySources", function()
  vim.cmd( "edit " .. vim.fn .system("python3 -c 'import site; print(site.getsitepackages()[0])'") :gsub("%s+$", "") .. "/.")
end, {})
vim.api.nvim_create_user_command("RustSources", function()
  local registry = os.getenv("CARGO_HOME")
    or (os.getenv("HOME") .. "/.cargo") .. "/registry/src"
  vim.cmd(
    "edit " .. registry .. "/" .. vim.fn.systemlist("ls -1 " .. registry)[1]
  )
end, {})
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.highlight.on_yank() end,
  group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
  pattern = "*",
})
vim.wo.foldmethod = "expr"
vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.cmd("colorscheme retrobox")
vim.api.nvim_set_hl(0, "Normal", { fg = "#ffaf00" })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.cmd("TSEnable highlight")
    vim.cmd("TSDisable highlight")
  end,
})
-- Mom, can we have telescope? No, we have telescope at home. Telescope at home:
local function run_search(cmd)
  local output = vim.fn.systemlist(cmd)
  vim.cmd("enew")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, output)
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false
end

vim.api.nvim_create_user_command("FileSearch", function(opts)
  local dir = opts.bang and vim.fn.expand("%:p:h") or vim.fn.getcwd()
  run_search( "find " .. vim.fn.shellescape(dir) .. " -name " .. "'*" .. opts.args .. "*'")
end, { nargs = "+", bang = true })

vim.api.nvim_create_user_command("TextSearch", function(opts)
  local path = opts.bang and vim.fn.expand("%:p:h") or vim.fn.getcwd()
  -- TODO(yobibyte): add .venv only to cwd search though. Doc search should include .venv.
  run_search("grep -IEnr --exclude-dir='*target*' --exclude-dir=.git --exclude-dir='*.egg-info' " .. "'" .. opts.args .. "' " .. path)
end, { nargs = "+", bang = true })

local function scratch_to_quickfix()
  local bufnr = vim.api.nvim_get_current_buf()
  local items = {}
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    if line ~= "" then
      local filename, lnum, text = line:match("^([^:]+):(%d+):(.*)$")
      if filename and lnum then
        --for grep filename:line:text
        table.insert(items, {
          filename = vim.fn.fnamemodify(filename, ":p"),
          lnum = tonumber(lnum),
          col = 1,
          text = text,
        })
      else
        -- for find results, only fnames
        table.insert(items, {
          filename = vim.fn.fnamemodify(line, ":p"),
          lnum = 1,
          col = 1,
          text = "",
        })
      end
    end
  end

  vim.fn.setqflist(items, "r")
  vim.cmd("copen")
  vim.cmd("cc")
  vim.api.nvim_buf_delete(bufnr, { force = true })
end

vim.keymap.set( "n", "<leader>cc", ":lua require('neogen').generate()<CR>", { noremap = true, silent = true })
vim.keymap.set("i", "jj", "<Esc>")
for i = 1, 9 do vim.keymap.set("n", string.format("<leader>%d", i), function() harpoon:list():select(i) end) end
vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
vim.keymap.set("n", "<leader>q", scratch_to_quickfix, {})
vim.keymap.set("n", "<leader>sf", function() vim.ui.input({ prompt = "> " }, function(name) if name then vim.cmd("FileSearch " .. name) end end) end, {})
vim.keymap.set("n", "<leader>lf", function() vim.ui.input({ prompt = "> " }, function(name) if name then vim.cmd("FileSearch! " .. name) end end) end, {})
vim.keymap.set("n", "<leader>sg", function() vim.ui.input({ prompt = "> " }, function(pattern) if pattern then vim.cmd("TextSearch " .. pattern) end end) end, {})
vim.keymap.set("n", "<leader>lg", function() vim.ui.input({ prompt = "> " }, function(pattern) if pattern then vim.cmd("TextSearch! " .. pattern) end end) end, {})
vim.keymap.set("n", "<leader>g", ":find ")
vim.keymap.set("n", "<leader>e", ":Explore<cr>")
