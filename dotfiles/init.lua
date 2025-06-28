vim.o.undofile    = true
vim.o.clipboard   = "unnamedplus"
vim.opt.expandtab = true
vim.cmd("syntax off | colorscheme retrobox | highlight Normal guifg=#ffaf00 guibg=#282828")

function _G.t(n) vim.opt_local.shiftwidth, vim.opt_local.tabstop, vim.opt_local.softtabstop = n, n, n end
local function ext(c, qf)
    o = vim.fn.systemlist(c) 
    if not (o and #o > 0) then return end
    vim.cmd("vnew") 
    vim.api.nvim_buf_set_lines(0, 0, -1, false, o) 
    vim.bo.buftype, vim.bo.bufhidden, vim.bo.swapfile = "nofile", "wipe", false
    if qf then vim.cmd("cgetbuffer | bd | copen | cc") end end

vim.api.nvim_create_autocmd("TextYankPost", { callback = function() vim.highlight.on_yank() end})
vim.api.nvim_create_autocmd({"BufEnter", "FileType"}, { callback = function() t(4)
    vim.b._reg_dir = vim.fn.system("python3 -c 'import site; print(site.getsitepackages()[0])'"):gsub("%s+$", "") 
    if vim.bo.filetype == "rust" then
        vim.b._reg_dir = vim.fn.system("echo ${CARGO_HOME:-$HOME/.cargo}/registry/src/") end
    local excs = { ".git", "*.egg-info", "__pycache__", "wandb", "target", ".venv" }
    vim.b._f_ex = table.concat(vim.tbl_map(function(e) return "-path '*" .. e .. "*' -prune -o" end, excs), " ")
    vim.b._g_ex = table.concat(vim.tbl_map(function(e) return "--exclude-dir='" .. e .. "'" end, excs), " ")
    vim.treesitter.stop() end})

vim.keymap.set("n", "<space>l", ":ls<cr>:b ")
vim.keymap.set("n", "<space>j", function() vim.fn.setreg('+', vim.b._reg_dir) end)
vim.keymap.set('n', '<space>y', function() vim.fn.setreg('+', vim.fn.expand('%:p')) end)
vim.keymap.set("n", "<space>c", function() vim.ui.input({}, function(c) if c then ext(c) end end) end)
vim.keymap.set("n", "<space>g", function() vim.ui.input({}, function(p) if p then 
    ext(string.format("grep -IEnr %s '%s' %s", vim.b._g_ex, p, vim.fn.getcwd()), true) end end) end)
vim.keymap.set("n", "<space>f", function() vim.ui.input({}, function(p) if p then 
    ext(string.format("find %s %s -path '*%s*' -print ", vim.fn.getcwd(), vim.b._f_ex, p)) end end) end)
