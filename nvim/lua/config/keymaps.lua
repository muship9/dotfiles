-- Basic keymaps
local keymap = vim.keymap.set

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Alternative window navigation (in case <C-l> conflicts)
keymap("n", "<leader>wh", "<C-w>h", { desc = "Go to left window" })
keymap("n", "<leader>wj", "<C-w>j", { desc = "Go to lower window" })
keymap("n", "<leader>wk", "<C-w>k", { desc = "Go to upper window" })
keymap("n", "<leader>wr", "<C-w>l", { desc = "Go to right window" })

-- Resize window using <ctrl> arrow keys
keymap("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
keymap("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
keymap("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
keymap("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Move Lines
keymap("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
keymap("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
keymap("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
keymap("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
keymap("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
keymap("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

-- Clear search with <esc>
keymap({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Better indenting
keymap("v", "<", "<gv")
keymap("v", ">", ">gv")

-- Save file
keymap({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Quit
keymap("n", "<leader>qq", "<cmd>qa!<cr>", { desc = "Quit all (force)" })
keymap("n", "<leader>qw", "<cmd>wqa<cr>", { desc = "Save all and quit" })
keymap("n", "<leader>qa", "<cmd>qa<cr>", { desc = "Quit all" })

-- Windows
keymap("n", "<leader>ww", "<C-W>p", { desc = "Other window" })
keymap("n", "<leader>wd", "<C-W>c", { desc = "Delete window" })
keymap("n", "<leader>wb", "<C-W>s", { desc = "Split window below (horizontal)" })
keymap("n", "<leader>wl", "<C-W>v", { desc = "Split window right (vertical)" })

-- Buffers
keymap("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
keymap("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
keymap("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
keymap("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
keymap("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
keymap("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
keymap("n", "<leader>bd", function()
  local current_buf = vim.api.nvim_get_current_buf()
  local all_bufs = vim.api.nvim_list_bufs()
  
  -- Find next valid buffer to switch to
  local next_buf = nil
  for _, buf in ipairs(all_bufs) do
    if buf ~= current_buf and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
      local bufname = vim.api.nvim_buf_get_name(buf)
      -- Skip Neo-tree and other special buffers
      if not bufname:match("neo%-tree") and vim.bo[buf].buftype == "" then
        next_buf = buf
        break
      end
    end
  end
  
  -- If we found a valid buffer, switch to it first
  if next_buf then
    vim.api.nvim_set_current_buf(next_buf)
  end
  
  -- Now delete the original buffer
  vim.cmd("bdelete " .. current_buf)
end, { desc = "Delete buffer (smart)" })

-- Copy relative path from git root
keymap("n", "<leader>cp", function()
  local file_path = vim.fn.expand("%:p")
  if file_path == "" then
    print("No file in buffer")
    return
  end
  
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    print("Not in a git repository")
    return
  end
  
  local relative_path = vim.fn.fnamemodify(file_path, ":s?" .. git_root .. "/??")
  vim.fn.setreg("+", relative_path)
  print("Copied: " .. relative_path)
end, { desc = "Copy relative path from git root" })

-- Git blame for current line
keymap("n", "<leader>gb", function()
  local file_path = vim.fn.expand("%:p")
  if file_path == "" then
    print("No file in buffer")
    return
  end
  
  local line = vim.fn.line(".")
  local blame_cmd = string.format("git blame -L %d,%d --date=relative %s", line, line, vim.fn.shellescape(file_path))
  local blame_output = vim.fn.systemlist(blame_cmd)
  
  if vim.v.shell_error ~= 0 then
    print("Git blame failed")
    return
  end
  
  if #blame_output > 0 then
    -- Parse the blame output
    local blame_line = blame_output[1]
    local commit, author, date = blame_line:match("^(%S+)%s+%((.-)%s+(%S+%s+%S+)")
    
    if commit and author and date then
      -- Get commit message
      local msg_cmd = string.format("git log -1 --pretty=format:%%s %s", commit)
      local commit_msg = vim.fn.systemlist(msg_cmd)[1] or "No commit message"
      
      -- Show in a floating window
      local buf = vim.api.nvim_create_buf(false, true)
      local content = {
        string.format("Commit: %s", commit:sub(1, 8)),
        string.format("Message: %s", commit_msg),
        string.format("Author: %s", author),
        string.format("Date: %s", date),
      }
      
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
      
      -- Calculate width based on content
      local width = 0
      for _, line in ipairs(content) do
        width = math.max(width, #line)
      end
      width = math.min(width + 2, 80) -- Max width 80
      
      local height = #content
      local win = vim.api.nvim_open_win(buf, false, {
        relative = "cursor",
        row = 1,
        col = 0,
        width = width,
        height = height,
        style = "minimal",
        border = "rounded",
      })
      
      -- Auto close on cursor move
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        once = true,
        callback = function()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
          end
        end,
      })
    else
      print("Failed to parse git blame output")
    end
  end
end, { desc = "Git blame for current line" })

-- Open current file in GitHub
keymap("n", "<leader>gB", function()
  local file_path = vim.fn.expand("%:p")
  if file_path == "" then
    print("No file in buffer")
    return
  end
  
  -- Get git root
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    print("Not in a git repository")
    return
  end
  
  -- Get current branch
  local branch = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")[1]
  if vim.v.shell_error ~= 0 then
    print("Failed to get current branch")
    return
  end
  
  -- Get remote URL
  local remote_url = vim.fn.systemlist("git config --get remote.origin.url")[1]
  if vim.v.shell_error ~= 0 then
    print("No remote origin found")
    return
  end
  
  -- Convert SSH URL to HTTPS if needed
  remote_url = remote_url:gsub("^git@github%.com:", "https://github.com/")
  remote_url = remote_url:gsub("%.git$", "")
  
  -- Get relative path from git root
  local relative_path = vim.fn.fnamemodify(file_path, ":s?" .. git_root .. "/??")
  
  -- Get current line number
  local line = vim.fn.line(".")
  
  -- Construct GitHub URL
  local github_url = string.format("%s/blob/%s/%s#L%d", remote_url, branch, relative_path, line)
  
  -- Open in browser
  local open_cmd
  if vim.fn.has("mac") == 1 then
    open_cmd = "open"
  elseif vim.fn.has("unix") == 1 then
    open_cmd = "xdg-open"
  elseif vim.fn.has("win32") == 1 then
    open_cmd = "start"
  else
    print("Unsupported OS")
    return
  end
  
  vim.fn.system(string.format("%s %s", open_cmd, vim.fn.shellescape(github_url)))
  print("Opened in GitHub: " .. github_url)
end, { desc = "Open current file in GitHub" })