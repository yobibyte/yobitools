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

local function scratch_to_quickfix()
  local prev_bufnr = vim.fn.bufnr('#')
  local orig_name = vim.fn.bufname(prev_bufnr)
  local bufnr = vim.api.nvim_get_current_buf()
  local items = {}
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    if line ~= "" then
      local filename, lnum, text = line:match("^([^:]+):(%d+):(.*)$")
      if filename and lnum then
        --for grep filename:line:text
        table.insert(items, {
          filename = vim.fn.fnamemodify(filename, ":p"),
          lnum = tonumber(lnum),
          col = 1,
          text = text,
        })
      else
        local lnum, text = line:match("^(%d+):(.*)$")
        if lnum and text then
          table.insert(items, {
            filename = orig_name,
            lnum = tonumber(lnum),
            col = 1,
            text = text,
          })
        else
          -- for find results, only fnames
          table.insert(items, {
            filename = vim.fn.fnamemodify(line, ":p"),
            lnum = 1,
            col = 1,
            text = "",
          })
        end
      end
    end
  end

  vim.api.nvim_buf_delete(bufnr, { force = true })
  vim.fn.setqflist(items, "r")
  vim.cmd("copen")
  vim.cmd("cc")
end
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
