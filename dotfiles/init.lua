vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.clipboard = "unnamedplus"
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.timeoutlen = 300
vim.cmd("syntax off") vim.cmd("colorscheme retrobox") vim.api.nvim_set_hl(0, "Normal", { fg = "#ffaf00" })
local pluginpath = vim.fn.stdpath("data") .. "/site/pack/plugins/start/"
if not vim.loop.fs_stat(pluginpath) then
  vim.fn.system({ "git", "clone", "https://github.com/yobibyte/telescope.nvim", "--branch=0.1.x", pluginpath .. "telescope.nvim", })
  vim.opt.rtp:append(pluginpath .. "telescope.nvim")
  vim.fn.system({ "git", "clone", "https://github.com/yobibyte/plenary.nvim", pluginpath .. "plenary.nvim", })
end
local function scratch() vim.bo.buftype = "nofile" vim.bo.bufhidden = "wipe" vim.bo.swapfile = false end
vim.keymap.set("i", "jj", "<Esc>")
vim.keymap.set("n", ";;", ":w<cr>")
vim.keymap.set("n", "<C-n>", ":bn<cr>", {})
vim.keymap.set("n", "<C-p>", ":bp<cr>", {})
vim.keymap.set("n", "<C-j>", ":move .+1<CR>", {})
vim.keymap.set("n", "<C-k>", ":move .-2<CR>", {})
vim.keymap.set("v", "<C-j>", ":move '>+1<CR>gv", { noremap = true, silent = true })
vim.keymap.set("v", "<C-k>", ":move '<-2<CR>gv", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>e", ":Explore<cr>")
vim.keymap.set("n", "<leader>n", ":set number!<cr>")
vim.keymap.set("n", "<leader>sg", require("telescope.builtin").live_grep)
vim.keymap.set("n", "<leader>sr", require("telescope.builtin").resume, {})
vim.keymap.set("n", "<leader>gl",      function() vim.cmd("vnew") vim.api.nvim_buf_set_lines( 0, 0, -1, false, vim.split(vim.fn.system({"git", "log"}), "\n")) scratch() end, {})
vim.keymap.set("n", "<leader>gd",      function() vim.cmd("vnew") vim.api.nvim_buf_set_lines( 0, 0, -1, false, vim.split(vim.fn.system({"git", "diff"}), "\n")) scratch() end, {})
vim.keymap.set("n", "<leader>gb",      function() local fpath = vim.fn.expand("%") vim.cmd("vnew") vim.api.nvim_buf_set_lines( 0, 0, -1, false, vim.split(vim.fn.system({"git", "blame", fpath}), "\n")) scratch() end, {})
vim.keymap.set("n", "<leader>gs",      function() local hash = vim.fn.expand("<cword>") vim.cmd("vnew") vim.api.nvim_buf_set_lines( 0, 0, -1, false, vim.split(vim.fn.system({"git", "show", hash}), "\n")) scratch() end, {})
vim.keymap.set("n", "<leader><space>", function() require("telescope.builtin").buffers { previewer = false, layout_strategy = "center", layout_config = { height = 0.4, }, } end)
vim.keymap.set("n", "<leader>sf",      function() require("telescope.builtin").find_files { previewer = false, layout_strategy = "center", layout_config = { height = 0.4, }, } end)
vim.keymap.set("n", "<leader>so",      function() require("telescope.builtin").oldfiles { previewer = false, layout_strategy = "center", layout_config = { height = 0.4, }, } end)
vim.keymap.set("n", "<leader>sb",      function() local fpath = vim.fn.expand("%:p") if fpath ~= "" then require("telescope.builtin").live_grep({ search_dirs = { fpath } }) end end)
vim.keymap.set("n", "<leader>df",      function() require("telescope.builtin").find_files({ cwd = vim.fn.expand("%:p:h"), no_ignore = true, }) end, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>ds",      function() require("telescope.builtin").live_grep({ cwd = vim.fn.expand("%:p:h"), additional_args = function() return { "--hidden", "--no-ignore" } end, }) end, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>gp",      function() vim.cmd( "edit " .. vim.fn .system("python3 -c 'import site; print(site.getsitepackages()[0])'") :gsub("%s+$", "") .. "/.") end)
vim.keymap.set("n", "<leader>gr",      function() local registry = os.getenv("CARGO_HOME") or (os.getenv("HOME") .. "/.cargo") .. "/registry/src" vim.cmd( "edit " .. registry .. "/" .. vim.fn.systemlist("ls -1 " .. registry)[1]) end)
vim.keymap.set("n", "<leader>bb",      ":!black %<cr>")
vim.keymap.set("n", "<leader>br",      function() vim.cmd("vnew") vim.api.nvim_buf_set_lines( 0, 0, -1, false, vim.split(vim.fn.system({ "ruff", "check", vim.fn.expand("#") }), "\n")) scratch() end, {})
vim.api.nvim_create_autocmd("TextYankPost", { callback = function() vim.highlight.on_yank() end, group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }), pattern = "*", })
vim.api.nvim_create_autocmd("BufReadPost", { callback = function()
    local space_count, tab_count = 0, 0
    local min_indent
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
