-- Just custom, self-written experimental stuff for nvim.
-- buflist to quickfix list
vim.keymap.set('n', '<leader>bl', function()
  local qf_list = {}
  for _, buf in ipairs(vim.fn.getbufinfo()) do
    if buf.listed == 1 then
      table.insert(qf_list, {
        filename = buf.name ~= '' and buf.name or '[No Name]',
        text = ':' .. buf.bufnr
      })
    end
  end
  vim.fn.setqflist(qf_list, 'r')
  vim.cmd('copen')
end, {})

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
  local path = opts.bang and vim.fn.expand("%:p:h") or vim.fn.getcwd()
  local excludes = "-path '*.egg-info*' -prune -o -path '*.git*' -prune -o -path '*__pycache__*' -prune -o"
  if not opts.bang then
    excludes = excludes .. " -path '*.venv*' -prune -o"
    excludes = excludes .. " -path '" .. vim.fn.getcwd() .. "/target*'" .. " -prune -o"
  end
  run_search("find " .. vim.fn.shellescape(path) .. " " .. excludes .. " " .. " -name " .. "'*" .. opts.args .. "*' -print")
end, { nargs = "+", bang = true })

vim.api.nvim_create_user_command("GrepTextSearch", function(opts)
  local path = opts.bang and vim.fn.expand("%:p:h") or vim.fn.getcwd()
  local excludes = "--exclude-dir='*target*' --exclude-dir=.git --exclude-dir='*.egg-info' --exclude-dir='__pycache__'"
  if not opts.bang then
    -- cwd search should only look at project files.
    excludes = excludes .. " --exclude-dir=.venv"
  end
  run_search("grep -IEnr "  .. excludes .. " '" .. opts.args .. "' " .. path)
end, { nargs = "+", bang = true })

vim.api.nvim_create_user_command("TextSearch", function(opts)
  local path = opts.bang and vim.fn.expand("%:p:h") or vim.fn.getcwd()
  local excludes = "--glob '!**/target/**' --glob '!.git/**' --glob '!**/*.egg-info/**' --glob '!**/__pycache__/**'"
  if not opts.bang then
    excludes = excludes .. " --glob '!**/.venv/**'"
  else
    excludes = excludes .. " --no-ignore "
  end
  local cmd = "rg --vimgrep -i -n " .. excludes .. " '" .. opts.args .. "' " .. path
  run_search(cmd)

end, { nargs = "+", bang = true })

vim.keymap.set("n", "<leader>q", scratch_to_quickfix)
vim.keymap.set("n", "<leader>sf", function() vim.ui.input({ prompt = "> " }, function(name) if name then vim.cmd("FileSearch " .. name) end end) end)
vim.keymap.set("n", "<leader>lf", function() vim.ui.input({ prompt = "> " }, function(name) if name then vim.cmd("FileSearch! " .. name) end end) end)
vim.keymap.set("n", "<leader>sg", function() vim.ui.input({ prompt = "> " }, function(pattern) if pattern then vim.cmd("TextSearch " .. pattern) end end) end)
vim.keymap.set("n", "<leader>lg", function() vim.ui.input({ prompt = "> " }, function(pattern) if pattern then vim.cmd("TextSearch! " .. pattern) end end) end)
vim.keymap.set("n", "<leader>/", function()
  vim.ui.input({ prompt = "> " }, function(pattern)
    if not pattern or pattern == "" then return end
    run_search("grep -n '" .. pattern .. "' " .. vim.fn.shellescape(vim.api.nvim_buf_get_name(0)))
  end)
end)
---- end of custom telescope 
--- in case I ever want to go back to telescope
local pluginpath = vim.fn.stdpath("data") .. "/site/pack/plugins/start/"
if not vim.loop.fs_stat(pluginpath) then
  vim.fn.system({ "git", "clone", "https://github.com/yobibyte/telescope.nvim", "--branch=0.1.x", pluginpath .. "telescope.nvim", })
  vim.opt.rtp:append(pluginpath .. "telescope.nvim")
  vim.fn.system({ "git", "clone", "https://github.com/yobibyte/plenary.nvim", pluginpath .. "plenary.nvim", })
end
vim.keymap.set("n", "<leader>sf", function() 
  local config = { previewer = false, layout_strategy = "center", layout_config = { height = 0.4, }, } 
  if vim.bo.filetype == "netrw" then config.cwd = vim.fn.expand("%:p:h") config.no_ignore = true end
  require("telescope.builtin").find_files(config)
end)
vim.keymap.set("n", "<leader>sg", function() 
  local config = {}
  if vim.bo.filetype == "netrw" then
    config.search_dirs = {vim.b.netrw_curdir} 
    config.additional_args = function() return { "--hidden", "--no-ignore" } end
  end
  require("telescope.builtin").live_grep(config)
end)
vim.keymap.set("n", "<leader>o",  function() vim.cmd.edit(vim.fn.fnameescape(vim.fn.trim(vim.fn.getreg("+")))) end)
vim.keymap.set("n", "<C-j>", ":move .+1<CR>")
vim.keymap.set("n", "<C-k>", ":move .-2<CR>")
vim.keymap.set("v", "<C-j>", ":move '>+1<CR>gv")
vim.keymap.set("v", "<C-k>", ":move '<-2<CR>gv")
