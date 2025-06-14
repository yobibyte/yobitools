vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.clipboard = "unnamedplus"
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.autoread = true
vim.o.timeoutlen = 300
vim.o.wildignorecase = true
vim.g.netrw_banner = 0
vim.opt.path:append("**")
vim.opt.wildignore:append {"*.venv/*", "*/.git/*", "*/target/*", "*/__pycache__/*"}
vim.cmd("syntax off") 
vim.cmd("colorscheme retrobox") 
vim.api.nvim_set_hl(0, "Normal", { fg = "#ffaf00" })

vim.api.nvim_create_autocmd("TextYankPost", { callback = function() vim.highlight.on_yank() end, group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }), pattern = "*", })
vim.api.nvim_create_autocmd("BufReadPost", { callback = function()
    local space_count, tab_count, min_indent = 0, 0, 8
    for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, 100, false)) do
      if not line:match("^%s*$") then
        local indent = line:match("^(%s+)")
        if indent then
          if indent:find("\t") then
            tab_count = tab_count + 1
          else
            space_count = space_count + 1
            min_indent = math.min(min_indent, #indent)
    end end end end
    vim.opt_local.expandtab = false
    if tab_count <= space_count then
      vim.opt_local.expandtab = true
      vim.opt_local.shiftwidth = min_indent
      vim.opt_local.tabstop = min_indent
      vim.opt_local.softtabstop = min_indent
end end, })

local function scratch_to_quickfix()
  local prev_bufnr = vim.fn.bufnr('#')
  local orig_name = vim.fn.bufname(prev_bufnr)
  local bufnr = vim.api.nvim_get_current_buf()
  local items = {}
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    if line ~= "" then
      local filename, lnum, text = line:match("^([^:]+):(%d+):(.*)$")
      if filename and lnum then
        -- for grep filename:line:text
        table.insert(items, { filename = vim.fn.fnamemodify(filename, ":p"), lnum = tonumber(lnum), col = 1, text = text, })
      else
        local lnum, text = line:match("^(%d+):(.*)$")
        if lnum and text then
          -- for current buffer grep
          table.insert(items, { filename = orig_name, lnum = tonumber(lnum), col = 1, text = text, })
        else
          -- for find results, only fnames
          table.insert(items, { filename = vim.fn.fnamemodify(line, ":p"), lnum = 1, col = 1, text = "", })
  end end end end
  vim.api.nvim_buf_delete(bufnr, { force = true })
  vim.fn.setqflist(items, "r")
  vim.cmd("copen | cc")
end

local function extcmd(cmd, use_list, quickfix) 
  if use_list then
    output = vim.fn.systemlist(cmd)
    if not output or #output == 0 then return end
  else
    output = vim.fn.system(cmd)
    if not output or output == "" then return end
    output = vim.split(output, "\n")
  end
  vim.cmd("vnew") vim.api.nvim_buf_set_lines( 0, 0, -1, false, output)
  vim.bo.buftype = "nofile" vim.bo.bufhidden = "wipe" vim.bo.swapfile = false
  if quickfix then scratch_to_quickfix() end
end

vim.api.nvim_create_user_command("FileSearch", function(opts)
  local excludes = "-path '*.egg-info*' -prune -o -path '*.git*' -prune -o -path '*__pycache__*' -prune -o"
  if vim.bo.filetype == "netrw" then
      path = vim.b.netrw_curdir
  else
      path = vim.fn.getcwd()
      excludes = excludes .. " -path '*/.venv*' -prune -o" .. " -path '" .. path .. "/target*'" .. " -prune -o"
  end
  extcmd("find " .. vim.fn.shellescape(path) .. " " .. excludes .. " " .. " -name " .. "'*" .. opts.args .. "*' -print", true, true)
end, { nargs = "+", })

vim.api.nvim_create_user_command("GrepTextSearch", function(opts)
  local path = opts.bang and vim.fn.expand("%:p:h") or vim.fn.getcwd()
  local excludes = "--exclude-dir='*target*' --exclude-dir=.git --exclude-dir='*.egg-info' --exclude-dir='__pycache__'"
  if vim.bo.filetype == "netrw" then path = vim.b.netrw_curdir else excludes = excludes .. " --exclude-dir=.venv" end
  extcmd("grep -IEnr "  .. excludes .. " '" .. opts.args .. "' " .. path, true, true)
end, { nargs = "+"})

vim.keymap.set("i", "jj", "<Esc>")
vim.keymap.set("n", ";;", ":w<cr>")
vim.keymap.set("n", "<leader>q", ":q!<cr>")
vim.keymap.set("n", "<leader>d", ":bd<cr>")
vim.keymap.set("n", "<leader>f", ":find **/*")
vim.keymap.set("n", "<leader><space>", ":b ")
vim.keymap.set("n", "<C-n>", ":cn<cr>", {})
vim.keymap.set("n", "<C-p>", ":cp<cr>", {})
vim.keymap.set("n", "<C-q>", ":cclose<cr>", {})
vim.keymap.set("n", "<leader>n", ":bn<cr>")
vim.keymap.set("n", "<leader>p", ":bp<cr>")
vim.keymap.set("n", "<C-j>", ":move .+1<CR>", {})
vim.keymap.set("n", "<C-k>", ":move .-2<CR>", {})
vim.keymap.set("v", "<C-j>", ":move '>+1<CR>gv")
vim.keymap.set("v", "<C-k>", ":move '<-2<CR>gv")
vim.keymap.set("n", "<leader>e", ":Explore<cr>")
vim.keymap.set("n", "<leader>w", ":set number!<cr>")
vim.keymap.set("n", "<leader>so",":browse oldfiles<cr>")
vim.keymap.set("n", "<leader>x",  scratch_to_quickfix)
vim.keymap.set("n", "<leader>o",  function() vim.cmd.edit(vim.fn.fnameescape(vim.fn.trim(vim.fn.getreg("+")))) end)
vim.keymap.set("n", "<leader>gl", function() extcmd({"git", "log"}) end)
vim.keymap.set("n", "<leader>gd", function() extcmd({"git", "diff"}) end)
vim.keymap.set("n", "<leader>gb", function() extcmd({"git", "blame", vim.fn.expand("%")}) end)
vim.keymap.set("n", "<leader>gs", function() extcmd({"git", "show", vim.fn.expand("<cword>")}) end)
vim.keymap.set("n", "<leader>gp", function() vim.cmd("edit " .. vim.fn.system("python3 -c 'import site; print(site.getsitepackages()[0])'") :gsub("%s+$", "") .. "/.") end)
vim.keymap.set("n", "<leader>gr", function() local registry = os.getenv("CARGO_HOME") or (os.getenv("HOME") .. "/.cargo") .. "/registry/src" vim.cmd( "edit " .. registry .. "/" .. vim.fn.systemlist("ls -1 " .. registry)[1]) end)
vim.keymap.set("n", "<leader>sf", function() vim.ui.input({ prompt = "> " }, function(name) if name then vim.cmd("FileSearch " .. name) end end) end)
vim.keymap.set("n", "<leader>sg", function() vim.ui.input({ prompt = "> " }, function(name) if name then vim.cmd("GrepTextSearch " .. name) end end) end)
vim.keymap.set("n", "<leader>bb",":!black %<cr>")
vim.keymap.set("n", "<leader>br",function() extcmd({ "ruff", "check", vim.fn.expand("#") }) end)
vim.keymap.set("n", "<leader>ss", function()
  vim.ui.input({ prompt = "> " }, function(pattern) if not pattern or pattern == "" then return end extcmd("grep -in '" .. pattern .. "' " .. vim.fn.shellescape(vim.api.nvim_buf_get_name(0)), true, false) end)
end)
