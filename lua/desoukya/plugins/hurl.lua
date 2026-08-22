-- Pick a Hurl env file (*.env next to the current .hurl) via a Telescope
-- picker (routed through dressing.nvim's vim.ui.select), then activate it
-- with :HurlSetEnvFile so the next run uses it.
local function pick_hurl_env()
  local start = vim.fn.expand("%:p:h")
  if start == "" then
    start = vim.fn.getcwd()
  end

  -- Collect *.env from the buffer's dir up through its ancestors. Stop at the
  -- git root if there is one, otherwise walk to the filesystem root — so env
  -- files kept at the project root are found from any subdirectory, git or not.
  local git_root = vim.fs.root(start, ".git")
  local files, seen = {}, {}
  local cur = start
  while true do
    for _, f in ipairs(vim.fn.glob(cur .. "/*.env", false, true)) do
      if not seen[f] then
        seen[f] = true
        files[#files + 1] = f
      end
    end
    if git_root and cur == git_root then
      break
    end
    local parent = vim.fn.fnamemodify(cur, ":h")
    if parent == cur then
      break
    end
    cur = parent
  end

  if #files == 0 then
    vim.notify("Hurl: no .env files found above " .. start, vim.log.levels.WARN)
    return
  end

  vim.ui.select(files, {
    prompt = "Hurl env file",
    format_item = function(f)
      return vim.fn.fnamemodify(f, ":~:.") -- show a path so same-named files stay distinct
    end,
  }, function(choice)
    if not choice then
      return
    end
    local name = vim.fn.fnamemodify(choice, ":t")
    -- Point hurl.nvim directly at the chosen file's absolute path. hurl_runner
    -- injects `--variables-file <path>` for each entry find_env_files_in_folders
    -- returns (gated on filereadable), so overriding it makes the picked file
    -- work regardless of where it lives or whether we're in a git repo.
    if _HURL_GLOBAL_CONFIG then
      _HURL_GLOBAL_CONFIG.env_file = { name }
      _HURL_GLOBAL_CONFIG.find_env_files_in_folders = function()
        return { { path = choice, dest = vim.fn.stdpath("cache") .. "/" .. name } }
      end
    end
    vim.notify("Hurl env → " .. vim.fn.fnamemodify(choice, ":~:."))
  end)
end

-- Pick a request from the current .hurl file via a Telescope picker (routed
-- through dressing.nvim's vim.ui.select), jump to it, and run it with
-- :HurlRunnerAt. The preceding `# comment` (if any) is used as the label.
local HTTP_METHODS = { GET = true, POST = true, PUT = true, DELETE = true, PATCH = true, HEAD = true, OPTIONS = true }

local function pick_hurl_request()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local requests = {}
  local label = nil
  for i, line in ipairs(lines) do
    local comment = line:match("^%s*#%s*(.+)")
    local method, url = line:match("^%s*([A-Z]+)%s+(.+)")
    if comment then
      label = comment
    elseif method and HTTP_METHODS[method] then
      local display = string.format("%3d  %s %s", i, method, url)
      if label then
        display = display .. "   — " .. label
      end
      table.insert(requests, { lnum = i, display = display })
      label = nil
    end
  end
  if #requests == 0 then
    vim.notify("Hurl: no requests found in this file", vim.log.levels.WARN)
    return
  end
  vim.ui.select(requests, {
    prompt = "Hurl request",
    format_item = function(r)
      return r.display
    end,
  }, function(choice)
    if not choice then
      return
    end
    vim.api.nvim_win_set_cursor(0, { choice.lnum, 0 })
    vim.cmd("HurlRunnerAt")
  end)
end

-- Open the last Hurl response in the browser, which has a real bidirectional
-- text engine — so RTL/Arabic values render correctly. Neither Neovim nor a
-- terminal can reorder bidi text, so this is the reliable way to *read* them.
local function open_last_response_in_browser()
  local ok, history = pcall(require, "hurl.history")
  local resp = ok and history.get_last_response and history.get_last_response()
  if not resp or not resp.body then
    vim.notify("Hurl: no response yet — run a request first", vim.log.levels.WARN)
    return
  end
  local body = resp.body
  local pretty = vim.fn.system({ "jq", "." }, body) -- pretty-print if it's JSON
  if vim.v.shell_error == 0 and pretty ~= "" then
    body = pretty
  end
  body = body:gsub("&", "&amp;"):gsub("<", "&lt;")
  local lines = {
    '<!doctype html><meta charset="utf-8">',
    "<style>body{font:14px/1.6 ui-monospace,Menlo,monospace;margin:1.5rem}</style>",
    '<pre dir="auto">', -- dir="auto" lets the browser bidi-order each line
  }
  vim.list_extend(lines, vim.split(body, "\n"))
  lines[#lines + 1] = "</pre>"
  local tmp = vim.fn.tempname() .. ".html"
  vim.fn.writefile(lines, tmp)
  vim.ui.open(tmp)
end

-- Report the byte size of the last Hurl response body (works even when the
-- server sends no Content-Length header).
local function show_last_response_size()
  local ok, history = pcall(require, "hurl.history")
  local resp = ok and history.get_last_response and history.get_last_response()
  if not resp or not resp.body then
    vim.notify("Hurl: no response yet — run a request first", vim.log.levels.WARN)
    return
  end
  local bytes = #resp.body
  local human
  if bytes < 1024 then
    human = bytes .. " B"
  elseif bytes < 1024 * 1024 then
    human = string.format("%.1f KB", bytes / 1024)
  else
    human = string.format("%.2f MB", bytes / (1024 * 1024))
  end
  vim.notify(string.format("Hurl: response body %s (%d bytes)", human, bytes))
end

return {
  "jellydn/hurl.nvim",
  ft = "hurl", -- load when a .hurl file is opened
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
  },
  opts = {
    debug = false,
    show_notification = false,
    mode = "split", -- show response in a side split ("popup" for a floating window)
  },
  keys = {
    { "<leader>ra", "<cmd>HurlRunnerAt<cr>", desc = "Hurl: run request at cursor" },
    { "<leader>rA", "<cmd>HurlRunner<cr>", desc = "Hurl: run all requests in file" },
    { "<leader>rr", ":HurlRunner<cr>", desc = "Hurl: run selected requests", mode = "v" },
    { "<leader>rl", "<cmd>HurlShowLastResponse<cr>", desc = "Hurl: show last response" },
    { "<leader>ro", open_last_response_in_browser, desc = "Hurl: open last response in browser (bidi/Arabic)" },
    { "<leader>rz", show_last_response_size, desc = "Hurl: show last response size" },
    { "<leader>re", pick_hurl_env, desc = "Hurl: select env file" },
    { "<leader>rp", pick_hurl_request, desc = "Hurl: pick & run a request" },
    { "<leader>rt", "<cmd>HurlToggleMode<cr>", desc = "Hurl: toggle split/popup view" },
    { "<leader>rv", "<cmd>HurlManageVariable<cr>", desc = "Hurl: manage variables (view/edit/delete)" },
    { "<leader>rs", ":HurlSetVariable ", desc = "Hurl: set a variable (type: name value)" },
  },
}
