vim.g.mapleader   = " "    vim.g.maplocalleader = " "
vim.o.ignorecase  = true   vim.o.smartcase      = true
vim.o.breakindent = true   vim.o.undofile       = true
vim.opt.expandtab = true   vim.o.clipboard      = "unnamedplus"
vim.cmd("syntax off | colorscheme retrobox") vim.api.nvim_set_hl(0, "Normal", { fg = "#ffaf00" })
vim.api.nvim_create_autocmd("TextYankPost", { callback = function() vim.highlight.on_yank() end, group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }), pattern = "*", })
vim.api.nvim_create_autocmd("FileType",     { callback = function() local i = 4 for _, l in ipairs(vim.api.nvim_buf_get_lines(0, 0, 50, false)) do local c = l:match("^(%s+)%S") if c then i = math.min(i, #c) end end vim.opt_local.shiftwidth=i vim.opt_local.tabstop=i vim.opt_local.softtabstop = i end , })
local function pre_search(is_grep) local path, exc, ex = vim.fn.getcwd(), { ".git", "*.egg-info", "__pycache__", "wandb", "target", ".venv", }, {} if vim.bo.filetype == "netrw" then path, exc = vim.b.netrw_curdir, { ".git", "*.egg-info", "__pycache__", "wandb","target" }  end 
  for i=1,#exc do if is_grep then table.insert(ex, string.format("--exclude-dir='%s'", exc[i])) else table.insert(ex, string.format("-path '*%s*' -prune -o", exc[i])) end end return path, table.concat(ex, " ") end
local function cqf(cls) local items, bufnr = {}, vim.api.nvim_get_current_buf() for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do if line ~= "" then local f, ln, text = line:match("^([^:]+):(%d+):(.*)$")
  if f and ln then table.insert(items, { filename = vim.fn.fnamemodify(f, ":p"), lnum = ln, text = text, }) else local ln, text = line:match("^(%d+):(.*)$") table.insert(items, { filename = vim.fn.bufname(vim.fn.bufnr("#")), lnum = ln, text = text, }) end end end 
  vim.api.nvim_buf_delete(bufnr, { force = true }) vim.fn.setqflist(items, "r") vim.cmd("copen | cc") if cls then vim.cmd("cclose") end end
local function extc(cmd, qf, cls, novs) o = vim.fn.systemlist(cmd) if o and #o > 0 then vim.cmd(novs and "enew" or "vnew") vim.api.nvim_buf_set_lines( 0, 0, -1, false, o) vim.bo.buftype = "nofile" vim.bo.bufhidden = "wipe" vim.bo.swapfile = false if qf then cqf(cls) end end end
vim.keymap.set("n", "<C-n>", ":cn<cr>")     vim.keymap.set("n", "<C-p>", ":cp<cr>")
vim.keymap.set("n", "<leader>n", ":bn<cr>") vim.keymap.set("n", "<leader>p", ":bp<cr>") vim.keymap.set("n", "<leader>d", ":bd<cr>")
vim.keymap.set("x", "<leader>p", "\"_dP")
vim.keymap.set("n", "<C-s>", function() vim.cmd(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and "cclose" or "copen") end)
vim.keymap.set("n", "<leader><space>", ":ls<cr>:b ")
vim.keymap.set("n", "<leader>e", ":Explore<cr>")
vim.keymap.set("n", "<leader>w", ":set number!<cr>")
vim.keymap.set("n", "<leader>x",  cqf)
vim.keymap.set("n", "<leader>h",  function() vim.bo.buftype = "" vim.bo.bufhidden = "hide" vim.bo.swapfile = true end)
vim.keymap.set("n", "<leader>gb", function() extc("git blame " .. vim.fn.expand("%"), false, false, true) end)
vim.keymap.set("n", "<leader>gs", function() extc("git show " .. vim.fn.expand("<cword>")) end)
vim.keymap.set("n", "<leader>gc", function() extc("git diff --name-only --diff-filter=U", true) end)
vim.keymap.set("n", "<leader>gd", function() if vim.bo.filetype == "rust" then local rg = os.getenv("CARGO_HOME") or (os.getenv("HOME") .. "/.cargo") .. "/registry/src" vim.cmd( "edit " .. rg .. "/" .. vim.fn.systemlist("ls -1 " .. rg)[1]) else vim.cmd("edit " .. vim.fn.system("python3 -c 'import site; print(site.getsitepackages()[0])'") :gsub("%s+$", "") .. "/.") end end)
vim.keymap.set("n", "<leader>ss", function() vim.ui.input({ prompt = "> " }, function(p) if p then extc("grep -in '" .. p .. "' " .. vim.fn.shellescape(vim.api.nvim_buf_get_name(0))) end end) end)
vim.keymap.set("n", "<leader>sg", function() vim.ui.input({ prompt = "> " }, function(p) if p then local path, ex = pre_search(true) extc(string.format("grep -IEnr %s '%s' %s", ex, p, path), true) end end) end)
vim.keymap.set("n", "<leader>sf", function() vim.ui.input({ prompt = "> " }, function(p) if p then local path, ex = pre_search(false) extc(string.format("find %s %s -path '*%s*' -print | awk '{ print $0 \":1: \" }'", vim.fn.shellescape(path), ex, p), true, true) end end) end)
vim.keymap.set("n", "<leader>l", function() local bn, ft = vim.fn.expand("%"), vim.bo.filetype if ft == "rust" then vim.fn.systemlist("cargo fmt") extc("cargo check && cargo clippy") elseif ft == "python" then extc("isort -q " .. bn .. "&& black -q " .. bn) extc("ruff check --output-format=concise --quiet " .. bn, true) vim.cmd("edit") end end)
local letters = "sdfghjkl" for i = 1, #letters do local l = letters:sub(i, i) vim.keymap.set('n', '<leader>a' .. l, "m" .. l:upper())  vim.keymap.set('n', '<leader>j' .. l, "'" .. l:upper()) end
vim.keymap.set("n", "<leader>c", function() vim.ui.input({ prompt = "> " }, function(c) if c then extc(c) end end) end)
