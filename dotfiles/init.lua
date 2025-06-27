vim.g.mapleader      = " "
vim.o.undofile       = true   
vim.o.smartcase      = true
vim.o.ignorecase     = true   
vim.opt.expandtab    = true   
vim.o.clipboard      = "unnamedplus"
vim.cmd("syntax off | colorscheme retrobox")
vim.api.nvim_set_hl(0, "Normal", { fg = "#ffaf00" })
local default_exclude = { ".git", "*.egg-info", "__pycache__", "wandb", "target", ".venv" }
local netrw_exclude   = { ".git", "*.egg-info", "__pycache__", "wandb", "target" }
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.highlight.on_yank() end,
  group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
  pattern = "*"
})
vim.api.nvim_create_autocmd("FileType", {
  callback = function() 
    local i = 4 
    for _, l in ipairs(vim.api.nvim_buf_get_lines(0, 0, 50, false)) do 
      local c = l:match("^(%s+)%S") 
      if c then i = math.min(i, #c) end
    end 
    vim.opt_local.shiftwidth=i 
    vim.opt_local.tabstop=i 
    vim.opt_local.softtabstop = i 
  end
})
local function ext(c) 
  o = vim.fn.systemlist(c) 
  if o and #o > 0 then 
    vim.cmd("vnew") 
    vim.api.nvim_buf_set_lines(0, 0, -1, false, o) 
    vim.bo.buftype = "nofile" 
    vim.bo.bufhidden = "wipe" 
    vim.bo.swapfile = false 
    return true
  end 
  return false
end
vim.keymap.set("n", "<C-n>", ":cn<cr>")
vim.keymap.set("n", "<C-p>", ":cp<cr>") 
vim.keymap.set("n", "<leader><space>", ":ls<cr>:b ")
vim.keymap.set('n', '<leader>y', function() vim.fn.setreg('+', vim.fn.expand('%:p')) end)
vim.keymap.set("n", "<leader>c", function() vim.ui.input({ prompt = "> " }, function(c) if c then ext(c) end end) end)
vim.keymap.set("n", "<leader>b", function() vim.ui.input({ prompt = "> " }, 
  function(p) if p then ext("grep -in '" .. p .. "' " .. vim.fn.shellescape(vim.fn.bufname("%"))) end
end) end)
vim.keymap.set("n", "<leader>g", function() vim.ui.input({ prompt = "> " }, function(p) if p then 
    local path, exc, ex = vim.fn.getcwd(), default_exclude, {} 
    if vim.bo.filetype == "netrw" then 
      path, exc = vim.b.netrw_curdir, netrw_exclude
    end 
    for i=1,#exc do table.insert(ex, string.format("--exclude-dir='%s'", exc[i])) end 
    if ext(string.format("grep -IEnr %s '%s' %s", table.concat(ex, " "), p, path), true) then
      local items = {} 
      for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do 
        if line ~= "" then 
          local f, ln, txt = line:match("^([^:]+):(%d+):(.*)$")
          if f and ln then 
            table.insert(items, { filename = vim.fn.fnamemodify(f, ":p"), lnum = ln, text = txt, }) 
      end end end 
      vim.api.nvim_buf_delete(0, { force = true })
      vim.fn.setqflist(items, "r")
      vim.cmd("copen | cc")  
end end end) end)
vim.keymap.set("n", "<leader>f", function() vim.ui.input({ prompt = "> " }, function(p) if p then 
  local path, exc, ex = vim.fn.getcwd(), default_exclude, {} 
  if vim.bo.filetype == "netrw" then 
    path, exc = vim.b.netrw_curdir, netrw_exclude
  end 
  for i=1,#exc do table.insert(ex, string.format("-path '*%s*' -prune -o", exc[i])) end 
  ext(string.format("find %s %s -path '*%s*' -print ", vim.fn.shellescape(path), table.concat(ex, " "), p))
end end) end)
vim.keymap.set("n", "<leader>j", function() 
  if vim.bo.filetype == "rust" then 
    vim.cmd("edit " .. vim.fn.system("find " .. (os.getenv("CARGO_HOME") or (os.getenv("HOME") .. "/.cargo"))  .. "/registry/src  -maxdepth 1 -mindepth 1 -print -quit"))
  else 
    vim.cmd("edit " .. vim.fn.system("python3 -c 'import site; print(site.getsitepackages()[0])'") :gsub("%s+$", "") .. "/.") 
  end 
end)
