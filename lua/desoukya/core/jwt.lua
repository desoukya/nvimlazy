-- Decode a JWT (header + payload) with no external plugins.
-- Uses Neovim's built-in vim.base64 + vim.json, and jq (if present) to pretty-print.
local M = {}

local function b64url_decode(segment)
  -- base64url -> base64: swap chars and pad to a multiple of 4
  local s = segment:gsub("-", "+"):gsub("_", "/")
  local pad = #s % 4
  if pad > 0 then
    s = s .. string.rep("=", 4 - pad)
  end
  local ok, decoded = pcall(vim.base64.decode, s)
  return ok and decoded or nil
end

local function pretty(json_str)
  if vim.fn.executable("jq") == 1 then
    local out = vim.fn.system({ "jq", "." }, json_str)
    if vim.v.shell_error == 0 and out ~= "" then
      return vim.split((out:gsub("%s+$", "")), "\n")
    end
  end
  local ok, tbl = pcall(vim.json.decode, json_str)
  return ok and vim.split(vim.inspect(tbl), "\n") or vim.split(json_str, "\n")
end

function M.decode(opts)
  -- Extract a JWT (three base64url segments separated by dots) rather than just
  -- stripping stray characters — so a token wrapped in `key=...`, quotes, or a
  -- `Bearer ...` header is picked up cleanly, from the cursor WORD or the line.
  local jwt_pat = "[%w_-]+%.[%w_-]+%.[%w_-]*"
  local token
  if opts and opts.args and opts.args ~= "" then
    token = opts.args:match(jwt_pat) or opts.args
  else
    token = vim.fn.expand("<cWORD>"):match(jwt_pat) or vim.api.nvim_get_current_line():match(jwt_pat)
  end

  local parts = token and vim.split(token, ".", { plain = true })
  if not parts or #parts < 2 or parts[1] == "" or parts[2] == "" then
    vim.notify("JWT: no valid token under cursor (or pass one: :JwtDecode <token>)", vim.log.levels.WARN)
    return
  end

  local header, payload = b64url_decode(parts[1]), b64url_decode(parts[2])
  if not header or not payload then
    vim.notify("JWT: failed to base64-decode the token", vim.log.levels.ERROR)
    return
  end

  local lines = { "// HEADER" }
  vim.list_extend(lines, pretty(header))
  table.insert(lines, "")
  table.insert(lines, "// PAYLOAD")
  vim.list_extend(lines, pretty(payload))

  -- decode common timestamp claims to human-readable local time
  local ok, claims = pcall(vim.json.decode, payload)
  if ok and type(claims) == "table" then
    local times = {}
    for _, k in ipairs({ "iat", "nbf", "exp" }) do
      if type(claims[k]) == "number" then
        local when = os.date("%Y-%m-%d %H:%M:%S", claims[k])
        local note = (k == "exp" and claims[k] < os.time()) and "  (EXPIRED)" or ""
        times[#times + 1] = string.format("%-4s %s%s", k, when, note)
      end
    end
    if #times > 0 then
      table.insert(lines, "")
      table.insert(lines, "// TIMES (local)")
      vim.list_extend(lines, times)
    end
  end

  vim.cmd("botright new")
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "json"
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].modifiable = false
  vim.api.nvim_win_set_height(0, math.min(#lines + 1, 25))
end

vim.api.nvim_create_user_command("JwtDecode", M.decode, {
  nargs = "?",
  desc = "Decode the JWT under the cursor (or given as an argument)",
})

vim.keymap.set("n", "<leader>jd", function()
  M.decode()
end, { desc = "Decode JWT under cursor" })

return M
