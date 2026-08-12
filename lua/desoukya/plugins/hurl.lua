-- Pick a Hurl env file (*.env next to the current .hurl) via a Telescope
-- picker (routed through dressing.nvim's vim.ui.select), then activate it
-- with :HurlSetEnvFile so the next run uses it.
local function pick_hurl_env()
  local dir = vim.fn.expand("%:p:h")
  if dir == "" then
    dir = vim.fn.getcwd()
  end
  local files = vim.fn.glob(dir .. "/*.env", false, true)
  if #files == 0 then
    vim.notify("Hurl: no .env files found in " .. dir, vim.log.levels.WARN)
    return
  end
  vim.ui.select(files, {
    prompt = "Hurl env file",
    format_item = function(f)
      return vim.fn.fnamemodify(f, ":t")
    end,
  }, function(choice)
    if not choice then
      return
    end
    local name = vim.fn.fnamemodify(choice, ":t")
    vim.cmd("HurlSetEnvFile " .. name)
    vim.notify("Hurl env → " .. name)
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
    mode = "popup", -- show response in a floating popup ("split" for a side window)
  },
  keys = {
    { "<leader>ra", "<cmd>HurlRunnerAt<cr>", desc = "Hurl: run request at cursor" },
    { "<leader>rA", "<cmd>HurlRunner<cr>", desc = "Hurl: run all requests in file" },
    { "<leader>rr", ":HurlRunner<cr>", desc = "Hurl: run selected requests", mode = "v" },
    { "<leader>rl", "<cmd>HurlShowLastResponse<cr>", desc = "Hurl: show last response" },
    { "<leader>re", pick_hurl_env, desc = "Hurl: select env file" },
    { "<leader>rp", pick_hurl_request, desc = "Hurl: pick & run a request" },
    { "<leader>rt", "<cmd>HurlToggleMode<cr>", desc = "Hurl: toggle split/popup view" },
    { "<leader>rv", "<cmd>HurlManageVariable<cr>", desc = "Hurl: manage variables (view/edit/delete)" },
    { "<leader>rs", ":HurlSetVariable ", desc = "Hurl: set a variable (type: name value)" },
  },
}
