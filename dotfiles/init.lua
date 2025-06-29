vim.o.undofile    = true
vim.o.clipboard   = "unnamedplus"
vim.opt.expandtab = true
vim.cmd("syntax off | colorscheme retrobox | highlight Normal guifg=#ffaf00 guibg=#282828")

function _G.t(n) 
    vim.opt_local.shiftwidth = n
    vim.opt_local.tabstop = n 
    vim.opt_local.softtabstop = n end

local ex = { ".git", "*.egg-info", "__pycache__", "wandb", "target", ".venv" }
if vim.fn.executable("rg") then
    local exc = table.concat( vim.tbl_map(function(dir) return "--glob='!" .. dir .. "/**'" end, ex), " ")
    vim.opt.grepprg = "rg --vimgrep -in " .. exc .. " -- $*"
else
    local exc = table.concat(vim.tbl_map(function(e) return "--exclude-dir='" .. e .. "'" end, ex), " ")
    vim.opt.grepprg = "grep -IEnr " .. exc .. " $* " .. vim.fn.getcwd()

vim.api.nvim_create_autocmd("TextYankPost", { callback = function() vim.highlight.on_yank()    end})
vim.api.nvim_create_autocmd("BufEnter",     { callback = function() vim.treesitter.stop() t(4) end})

vim.keymap.set("n", "<space>l", ":ls<cr>:b ")
vim.keymap.set("n", "<space>r", function() vim.fn.setreg('+', vim.fn.system("echo ${CARGO_HOME:-$HOME/.cargo}/registry/src/")) end)
vim.keymap.set("n", "<space>p", function() vim.fn.setreg('+', vim.fn.system("python3 -c 'import site; print(site.getsitepackages()[0])'"):gsub("%s+$", "")) end)
vim.keymap.set('n', '<space>y', function() vim.fn.setreg('+', vim.fn.expand('%:p')) end)
vim.keymap.set("n", "<space>c", function() vim.ui.input({}, function(c) if c then 
    o = vim.fn.systemlist(c) 
    if not (o and #o > 0) then return end
    vim.cmd("vnew") 
    vim.api.nvim_buf_set_lines(0, 0, -1, false, o) 
    vim.bo.buftype = "nofile"
    vim.bo.bufhidden = "wipe" 
    vim.bo.swapfile = false
end end) end)
