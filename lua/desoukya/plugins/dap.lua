-- Debugging via DAP (Debug Adapter Protocol).
-- Python uses debugpy from a dedicated venv: ~/.virtualenvs/debugpy
--   python3 -m venv ~/.virtualenvs/debugpy
--   ~/.virtualenvs/debugpy/bin/python -m pip install debugpy
-- To debug project code, run debugpy against your project's interpreter:
-- dap-python auto-detects a project venv (VIRTUAL_ENV or ./.venv|./venv). If you
-- hit "No module named debugpy", run `pip install debugpy` in that venv.
return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio", -- required by nvim-dap-ui
    "theHamsta/nvim-dap-virtual-text",
    "mfussenegger/nvim-dap-python",
  },
  keys = {
    -- VSCode-style function keys for the debug loop (no leader conflicts)
    { "<F5>", function() require("dap").continue() end, desc = "DAP: start / continue" },
    { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "DAP: toggle breakpoint" },
    { "<leader>B", function() require("dap").toggle_breakpoint() end, desc = "DAP: toggle breakpoint" },
    { "<F10>", function() require("dap").step_over() end, desc = "DAP: step over" },
    { "<F11>", function() require("dap").step_into() end, desc = "DAP: step into" },
    { "<F12>", function() require("dap").step_out() end, desc = "DAP: step out" },
    { "<F6>", function() require("dapui").toggle() end, desc = "DAP: toggle UI" },
    -- capitalized leader combos avoid pausing the lowercase <leader> commands
    {
      "<leader>E",
      function()
        require("dapui").eval(nil, { enter = true })
      end,
      mode = { "n", "v" },
      desc = "DAP: evaluate expression",
    },
    { "<leader>Q", function() require("dap").terminate() end, desc = "DAP: terminate session" },
    -- Python: debug the test under the cursor / the whole test class
    {
      "<leader>T",
      function() require("dap-python").test_method() end,
      desc = "DAP: debug nearest test (Python)",
      ft = "python",
    },
    {
      "<leader>C",
      function() require("dap-python").test_class() end,
      desc = "DAP: debug test class (Python)",
      ft = "python",
    },
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    dapui.setup()
    require("nvim-dap-virtual-text").setup()
    require("dap-python").setup(vim.fn.expand("~/.virtualenvs/debugpy/bin/python"))

    -- Attach to the Kawader AI server started via `just dev-debug`
    -- (server on :8080, debugpy listening on :5678). Pick this from <F5>.
    table.insert(dap.configurations.python, {
      type = "python",
      request = "attach",
      name = "Attach to Kawader AI (:5678)",
      connect = { host = "127.0.0.1", port = 5678 },
      justMyCode = false, -- allow stepping into library code (useful for learning)
    })

    -- open the UI automatically when a session starts, close it when it ends
    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end

    -- clearer breakpoint / stopped-line signs
    vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
    vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
    vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn", linehl = "Visual" })
  end,
}
