vim.g.mapleader   = " "
vim.o.undofile    = true   
vim.opt.expandtab = true   
vim.o.clipboard   = "unnamedplus"
vim.cmd("syntax off | colorscheme retrobox")
vim.api.nvim_set_hl(0, "Normal", { fg = "#ffaf00" })
vim.api.nvim_create_autocmd("TextYankPost", { callback = function() vim.highlight.on_yank() end, group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }), pattern = "*" })
vim.api.nvim_create_autocmd({"BufEnter", "FileType"}, { callback = function() 
    local i = 4 for _, l in ipairs(vim.api.nvim_buf_get_lines(0, 0, 50, false)) do local c = l:match("^(%s+)%S") if c then i = math.min(i, #c) end end 
    vim.opt_local.shiftwidth, vim.opt_local.tabstop, vim.opt_local.softtabstop = i, i, i 
    if vim.bo.filetype == "rust"  then vim.b._reg_dir = vim.fn.system("find $(echo ${CARGO_HOME:-$HOME/.cargo})/registry/src  -maxdepth 1 -mindepth 1 -print -quit")
    else vim.b._reg_dir = vim.fn.system("python3 -c 'import site; print(site.getsitepackages()[0])'"):gsub("%s+$", "") end
    vim.b._search_path = (vim.bo.filetype == "netrw") and vim.b.netrw_curdir or vim.fn.getcwd()
    excs = (vim.bo.filetype == "netrw") and { ".git", "*.egg-info", "__pycache__", "wandb", "target" } or { ".git", "*.egg-info", "__pycache__", "wandb", "target", ".venv" }
    vim.b._f_excs = table.concat(vim.tbl_map(function(e) return "-path '*" .. e .. "*' -prune -o" end, excs), " ")
    vim.b._g_excs = table.concat(vim.tbl_map(function(e) return "--exclude-dir='" .. e .. "'" end, excs), " ")
    if vim.treesitter and vim.treesitter.stop then vim.treesitter.stop() end end })
local function ext(c, novs) 
    o = vim.fn.systemlist(c) 
    if not (o and #o > 0) then return false end
    vim.cmd(novs and "enew" or "vnew") 
    vim.api.nvim_buf_set_lines(0, 0, -1, false, o) 
    vim.bo.buftype, vim.bo.bufhidden, vim.bo.swapfile = "nofile", "wipe", false
    return true end
vim.keymap.set("n", "<leader><space>", ":ls<cr>:b ")
vim.keymap.set("n", "<leader>j", function() vim.cmd("edit " .. vim.b._reg_dir) end)
vim.keymap.set('n', '<leader>y', function() vim.fn.setreg('+', vim.fn.expand('%:p')) end)
vim.keymap.set("n", "<leader>c", function() vim.ui.input({ prompt = "> " }, function(c) if c then ext(c) end end) end)
vim.keymap.set("n", "<leader>b", function() vim.ui.input({ prompt = "> " }, function(p) if p then ext("grep -in '" .. p .. "' " .. vim.fn.shellescape(vim.fn.bufname("%"))) end end) end)
vim.keymap.set("n", "<leader>g", function() vim.ui.input({ prompt = "> " }, function(p) if p then 
  if ext(string.format("grep -IEnr %s '%s' %s", vim.b._g_excs, p, vim.b._search_path), true) then vim.cmd("cgetbuffer | bd | copen | cc") end end end) end)
vim.keymap.set("n", "<leader>f", function() vim.ui.input({ prompt = "> " }, function(p) if p then 
  ext(string.format("find %s %s -path '*%s*' -print ", vim.fn.shellescape(vim.b._search_path), vim.b._f_excs, p), true)
  local l = vim.api.nvim_buf_get_lines(0, 0, -1, false) if #l == 1 then vim.cmd("edit " .. vim.fn.fnameescape(l[1])) end end end) end)
