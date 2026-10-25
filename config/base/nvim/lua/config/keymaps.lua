local map = vim.keymap.set

local function opts(desc)
  return { desc = desc, silent = true }
end

local function accept_completion_or(keys)
  if vim.fn.pumvisible() == 0 then
    return keys
  end

  if vim.fn.complete_info({ "selected" }).selected == -1 then
    return "<C-n><C-y>"
  end

  return "<C-y>"
end

-- Save / quit
map("n", "<leader>w", "<cmd>w<CR>", opts("Save file"))
map("n", "<leader>q", "<cmd>q<CR>", opts("Quit"))

-- Completion
map("i", "<Tab>", function()
  return accept_completion_or("<Tab>")
end, { desc = "Accept completion", expr = true })

map("i", "<CR>", function()
  return accept_completion_or("<CR>")
end, { desc = "Accept completion", expr = true })

map("i", "<C-Space>", function()
  if vim.lsp.completion then
    vim.lsp.completion.get()
  end
end, opts("Trigger LSP completion"))

local function open_lazygit(args)
  if vim.fn.executable("lazygit") == 0 then
    vim.notify("lazygit is not installed", vim.log.levels.ERROR)
    return
  end

  local original_columns = vim.o.columns
  local original_showtabline = vim.o.showtabline
  local zoomed_tmux_pane = false
  if vim.env.TMUX then
    local zoomed = vim.trim(vim.fn.system({ "tmux", "display-message", "-p", "#{window_zoomed_flag}" }))
    if vim.v.shell_error == 0 and zoomed == "0" then
      vim.fn.system({ "tmux", "resize-pane", "-Z" })
      zoomed_tmux_pane = vim.v.shell_error == 0
    end
  end
  vim.o.showtabline = 0
  if zoomed_tmux_pane then
    vim.wait(500, function()
      return vim.o.columns ~= original_columns
    end)
  end

  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.max(1, vim.o.columns - 2)
  local height = math.max(1, vim.o.lines - vim.o.cmdheight - 3)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = 0,
    col = 0,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
  })
  vim.api.nvim_set_option_value("winhighlight", "Normal:Normal,FloatBorder:FloatBorder", { win = win })

  vim.fn.termopen(args, {
    on_exit = function()
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
        if zoomed_tmux_pane then
          vim.fn.system({ "tmux", "resize-pane", "-Z" })
        end
        vim.o.showtabline = original_showtabline
      end)
    end,
  })
  vim.cmd("startinsert")
end

-- Open lazygit
map("n", "<leader>gg", function()
  open_lazygit({ "lazygit" })
end, opts("Open Lazygit"))

-- Open current file history in lazygit
map("n", "<leader>gh", function()
  local path = vim.fn.expand("%:p")
  if path == "" then
    vim.notify("Current buffer has no file", vim.log.levels.ERROR)
    return
  end

  open_lazygit({ "lazygit", "--filter", path })
end, opts("Open current file history in Lazygit"))

-- Open git remote repository
map("n", "<leader>go", function()
  local result = vim.system({ "git", "remote", "get-url", "origin" }, { text = true }):wait()
  local url = vim.trim(result.stdout or "")

  if result.code ~= 0 or url == "" then
    vim.notify("No git remote found", vim.log.levels.ERROR)
    return
  end

  -- Convert common SSH remote forms to browser-friendly HTTPS URLs.
  url = url:gsub("^git@([^:]+):", "https://%1/")
  url = url:gsub("^ssh://git@([^/]+)/", "https://%1/")
  url = url:gsub("%.git$", "")

  vim.ui.open(url)
end, opts("Open Git remote repository"))

-- Open current file with system viewer
map("n", "<leader>oi", function()
  local path = vim.fn.expand("%:p")
  if path == "" then
    vim.notify("Current buffer has no file", vim.log.levels.ERROR)
    return
  end

  vim.ui.open(path)
end, opts("Open current file with system viewer"))

-- Open current repository in a new Visual Studio Code window at the current file
map("n", "<leader>ov", function()
  if vim.fn.executable("code") == 0 then
    vim.notify("Visual Studio Code CLI is not installed", vim.log.levels.ERROR)
    return
  end

  local path = vim.fn.expand("%:p")
  if path == "" then
    vim.notify("Current buffer has no file", vim.log.levels.ERROR)
    return
  end

  local root = vim.fs.root(path, ".git")
  if not root then
    vim.notify("Current file is not in a Git repository", vim.log.levels.ERROR)
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local location = string.format("%s:%d:%d", path, cursor[1], cursor[2] + 1)

  vim.fn.jobstart({ "code", "--new-window", root, "--goto", location }, { detach = true })
end, opts("Open repository in Visual Studio Code"))

-- Open current buffer directory with system file manager
map("n", "<leader>od", function()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    vim.notify("Current buffer has no file", vim.log.levels.ERROR)
    return
  end

  local stat = vim.uv.fs_stat(path)
  local dir = stat and stat.type == "directory" and path or vim.fn.fnamemodify(path, ":p:h")

  vim.ui.open(dir)
end, opts("Open current buffer directory with system file manager"))
