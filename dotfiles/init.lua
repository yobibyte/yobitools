vim.o.undofile    = true   
vim.opt.expandtab = true   
vim.o.clipboard   = "unnamedplus"
vim.cmd("syntax off | colorscheme retrobox | highlight Normal guifg=#ffaf00 guibg=#282828")
vim.api.nvim_create_autocmd("TextYankPost", { callback = function() vim.highlight.on_yank() end})
vim.api.nvim_create_autocmd({"BufEnter", "FileType"}, { callback = function() 
    local i = 4 for _, l in ipairs(vim.api.nvim_buf_get_lines(0, 0, 50, false)) do 
        local c = l:match("^(%s+)%S") if c then i = math.min(i, #c) end end 
    vim.opt_local.shiftwidth, vim.opt_local.tabstop, vim.opt_local.softtabstop = i, i, i 
    if vim.bo.filetype == "rust"  then vim.b._reg_dir = vim.fn.system("echo ${CARGO_HOME:-$HOME/.cargo}/registry/src/")
    else vim.b._reg_dir = vim.fn.system("python3 -c 'import site; print(site.getsitepackages()[0])'"):gsub("%s+$", "") end
    if vim.bo.filetype == "netrw" then vim.b._search_path = vim.b.netrw_curdir
      excs = { ".git", "*.egg-info", "__pycache__", "wandb", "target" }
    else vim.b._search_path = vim.fn.getcwd()
      excs = { ".git", "*.egg-info", "__pycache__", "wandb", "target", ".venv" } end
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
vim.keymap.set("n", "<space>l", ":ls<cr>:b ")
vim.keymap.set("n", "<space>j", function() vim.cmd("edit " .. vim.b._reg_dir) end)
vim.keymap.set('n', '<space>y', function() vim.fn.setreg('+', vim.fn.expand('%:p')) end)
vim.keymap.set("n", "<space>c", function() vim.ui.input({ prompt = "> " }, function(c) if c then ext(c) end end) end)
vim.keymap.set("n", "<space>b", function() vim.ui.input({ prompt = "> " }, function(p) if p then 
  ext("grep -in '" .. p .. "' " .. vim.fn.shellescape(vim.fn.bufname("%"))) end end) end)
vim.keymap.set("n", "<space>g", function() vim.ui.input({ prompt = "> " }, function(p) if p then 
  if ext(string.format("grep -IEnr %s '%s' %s", vim.b._g_excs, p, vim.b._search_path), true) then
      vim.cmd("cgetbuffer | bd | copen | cc") end end end) end)
vim.keymap.set("n", "<space>f", function() vim.ui.input({ prompt = "> " }, function(p) if p then 
  ext(string.format("find %s %s -path '*%s*' -print ", vim.fn.shellescape(vim.b._search_path), vim.b._f_excs, p), true)
  local l = vim.api.nvim_buf_get_lines(0, 0, -1, false) if #l == 1 then vim.cmd("edit " .. vim.fn.fnameescape(l[1])) end end end) end)
