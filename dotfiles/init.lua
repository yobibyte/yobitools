vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.clipboard = "unnamedplus"
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.timeoutlen = 300
vim.g.netrw_banner = 0
_G.basic_excludes = { "*/.git*", "*.egg-info*", "*__pycache__*", "*wandb/*","*target*" }
_G.ext_excludes = vim.list_extend(vim.deepcopy(_G.basic_excludes), { "*/.venv*", })
vim.cmd("syntax off | colorscheme retrobox") vim.api.nvim_set_hl(0, "Normal", { fg = "#ffaf00" })
vim.api.nvim_create_autocmd("TextYankPost", { callback = function() vim.highlight.on_yank() end, group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }), pattern = "*", })
vim.api.nvim_create_autocmd("BufReadPost",  { callback = function() local space_count, tab_count, min_indent = 0, 0, 8
    for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, 100, false)) do local indent = line:match("^(%s+)")
      if indent and not line:match("^%s*$") then
          if indent:find("\t") then tab_count = tab_count + 1 else space_count = space_count + 1 min_indent = math.min(min_indent, #indent)
    end end end
    if tab_count <= space_count then vim.opt_local.expandtab, vim.opt_local.shiftwidth, vim.opt_local.tabstop, vim.opt_local.softtabstop = true, min_indent, min_indent, min_indent end end, })
local function scratch() vim.bo.buftype = "nofile" vim.bo.bufhidden = "wipe" vim.bo.swapfile = false end
local function pre_search() if vim.bo.filetype == "netrw" then return vim.b.netrw_curdir, _G.basic_excludes, {} else return vim.fn.getcwd(), _G.ext_excludes, {} end end
local function scratch_to_quickfix(close_qf)
  local items, bufnr = {}, vim.api.nvim_get_current_buf() 
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    if line ~= "" then
      local filename, lnum, text = line:match("^([^:]+):(%d+):(.*)$")
      if filename and lnum then
        table.insert(items, { filename = vim.fn.fnamemodify(filename, ":p"), lnum = tonumber(lnum), text = text, }) -- for grep filename:line:text
      else
        local lnum, text = line:match("^(%d+):(.*)$")
        if lnum and text then
          table.insert(items, { filename = vim.fn.bufname(vim.fn.bufnr("#")), lnum = tonumber(lnum), text = text, }) -- for current buffer grep
        else
          table.insert(items, { filename = vim.fn.fnamemodify(line, ":p") }) -- for find results, only fnames
  end end end end vim.api.nvim_buf_delete(bufnr, { force = true }) vim.fn.setqflist(items, "r") vim.cmd("copen | cc") if close_qf then vim.cmd("cclose") end end
local function extcmd(cmd, qf, close_qf, novsplit) 
  output = vim.fn.systemlist(cmd) if not output or #output == 0 then return end
  vim.cmd(novsplit and "enew" or "vnew") vim.api.nvim_buf_set_lines( 0, 0, -1, false, output) scratch() if qf then scratch_to_quickfix(close_qf) end end
vim.keymap.set("n", "<C-n>", ":cn<cr>")
vim.keymap.set("n", "<C-p>", ":cp<cr>")
vim.keymap.set("n", "<C-s>", function() vim.cmd(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and "cclose" or "copen") end)
vim.keymap.set("n", "<leader>q", ":qall!<cr>")
vim.keymap.set("n", "<leader>n", ":bn<cr>")
vim.keymap.set("n", "<leader>p", ":bp<cr>")
vim.keymap.set("n", "<leader>d", ":bd<cr>")
vim.keymap.set("n", "<leader><space>", ":b ")
vim.keymap.set("n", "<leader>e", ":Explore<cr>")
vim.keymap.set("n", "<leader>w", ":set number!<cr>")
vim.keymap.set("n", "<leader>x",  scratch_to_quickfix)
vim.keymap.set("n", "<leader>so", function() vim.cmd("enew")  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.v.oldfiles) scratch() end) 
vim.keymap.set("n", "<leader>gl", function() extcmd("git log", false, false, true) end)
vim.keymap.set("n", "<leader>gd", function() extcmd("git diff", false, false, true) end)
vim.keymap.set("n", "<leader>gb", function() extcmd("git blame " .. vim.fn.expand("%"), false, false, true) end)
vim.keymap.set("n", "<leader>gs", function() extcmd("git show " .. vim.fn.expand("<cword>"), false, false, true) end)
vim.keymap.set("n", "<leader>gp", function() vim.cmd("edit " .. vim.fn.system("python3 -c 'import site; print(site.getsitepackages()[0])'") :gsub("%s+$", "") .. "/.") end)
vim.keymap.set("n", "<leader>gr", function() local reg = os.getenv("CARGO_HOME") or (os.getenv("HOME") .. "/.cargo") .. "/registry/src" vim.cmd( "edit " .. reg .. "/" .. vim.fn.systemlist("ls -1 " .. reg)[1]) end)
vim.keymap.set("n", "<leader>ss", function() vim.ui.input({ prompt = "> " }, function(pat) if pat then extcmd("grep -in '" .. pat .. "' " .. vim.fn.shellescape(vim.api.nvim_buf_get_name(0)), false) end end) end)
vim.keymap.set("n", "<leader>sg", function() vim.ui.input({ prompt = "> " }, function(pat) if pat then 
  local path, excludes, parts = pre_search() for _, pattern in ipairs(excludes) do table.insert(parts, string.format("--exclude-dir='%s'", pattern)) end
  extcmd(string.format("grep -IEnr %s '%s' %s", table.concat(parts, " "), pat, path), true) end end, { nargs = "+" }) end)
vim.keymap.set("n", "<leader>sf", function() vim.ui.input({ prompt = "> " }, function(pat) if pat then 
  local path, excludes, parts = pre_search() for _, pattern in ipairs(excludes) do table.insert(parts, string.format("-path '%s' -prune -o", pattern)) end
  extcmd(string.format("find %s %s -name '*%s*' -print", vim.fn.shellescape(path), table.concat(parts, " "), pat), true, true) end end, { nargs = "+" }) end)
vim.keymap.set("n", "<leader>l", function() local bn = vim.fn.expand("%") extcmd("isort -q " .. bn .. "&& black -q " .. bn) extcmd("ruff check --output-format=concise --quiet " .. bn, true) vim.cmd("edit") end)
