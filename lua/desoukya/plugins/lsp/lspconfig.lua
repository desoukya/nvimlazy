return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "nvimdev/lspsaga.nvim",
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
  },
  config = function()
    local has_native_lsp = (type(vim.lsp.config) == "function" or type(vim.lsp.config) == "table")
      and type(vim.lsp.enable) == "function"

    -- import lspconfig plugin
    require("lspsaga").setup({
      -- keybinds for navigation in lspsaga window
      scroll_preview = { scroll_down = "<C-f>", scroll_up = "<C-b>" },
      -- use enter to open file with definition preview
      definition = {
        keys = {
          edit = "<cr>",
        },
      },
      ui = {
        colors = {
          normal_bg = "#022746",
        },
      },
    })

    local lspconfig = nil
    if not has_native_lsp then
      -- Fallback for older Neovim versions that don't support vim.lsp.config()/vim.lsp.enable().
      lspconfig = require("lspconfig")
    end

    -- import cmp-nvim-lsp plugin
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    local keymap = vim.keymap -- for conciseness

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf, silent = true }
        local telescope_ok, telescope_builtin = pcall(require, "telescope.builtin")
        local function supports_lsp_method(method)
          for _, client in ipairs(vim.lsp.get_clients({ bufnr = ev.buf })) do
            if client.supports_method(method) then
              return true
            end
          end
          return false
        end

        -- set keybinds
        opts.desc = "Show LSP references"
        keymap.set("n", "gf", function()
          if supports_lsp_method("textDocument/definition") or supports_lsp_method("textDocument/references") then
            vim.cmd("Lspsaga finder")
            return
          end
          -- Keep Vim's native `gf` behavior when no LSP is available for this buffer.
          vim.cmd("normal! gf")
        end, opts) -- show definition, references

        opts.desc = "Go to declaration"
        keymap.set("n", "ge", vim.lsp.buf.declaration, opts) -- go to declaration

        opts.desc = "Show LSP definitions"
        keymap.set("n", "gd", function()
          if supports_lsp_method("textDocument/definition") then
            vim.lsp.buf.definition()
            return
          end
          vim.notify("No LSP definition provider is attached to this buffer", vim.log.levels.WARN)
        end, opts) -- jump to lsp definition

        opts.desc = "Show LSP Incoming calls"
        keymap.set("n", "gc", function()
          if vim.lsp.buf.incoming_calls then
            vim.lsp.buf.incoming_calls()
            return
          end
          if telescope_ok and telescope_builtin.lsp_incoming_calls then
            telescope_builtin.lsp_incoming_calls()
            return
          end
          vim.notify("Incoming calls picker is unavailable", vim.log.levels.WARN)
        end, opts) -- show incoming calls

        opts.desc = "Show Spelling Recommendations"
        keymap.set("n", "gp", function()
          if telescope_ok and telescope_builtin.spell_suggest then
            telescope_builtin.spell_suggest()
            return
          end
          vim.cmd("normal! z=")
        end, opts) -- show spelling suggestions

        opts.desc = "See available code actions"
        keymap.set("n", "<leader>ga", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

        opts.desc = "Smart rename"
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

        opts.desc = "Show buffer diagnostics"
        keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

        opts.desc = "Show line diagnostics"
        keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

        opts.desc = "Go to previous diagnostic"
        keymap.set("n", "gj", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

        opts.desc = "Go to next diagnostic"
        keymap.set("n", "gk", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

        opts.desc = "Show documentation for what is under cursor"
        keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
      end,
    })

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Change the Diagnostic symbols in the sign column (gutter)
    -- (not in youtube nvim video)
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    local function resolve_typescript_server()
      if has_native_lsp then
        if type(vim.lsp.config) == "table" and vim.lsp.config.ts_ls then
          return "ts_ls"
        end
        -- On Neovim 0.11+ prefer ts_ls by default.
        return "ts_ls"
      else
        local ok, lspconfig_configs = pcall(require, "lspconfig.configs")
        if ok and lspconfig_configs and lspconfig_configs.ts_ls then
          return "ts_ls"
        end
      end
      return "tsserver"
    end

    local function setup_server(server_name, server_opts)
      local merged_opts = vim.tbl_deep_extend("force", {
        capabilities = capabilities,
      }, server_opts or {})

      if has_native_lsp then
        vim.lsp.config(server_name, merged_opts)
        vim.lsp.enable(server_name)
        return
      end

      if not lspconfig[server_name] then
        vim.notify(("LSP server '%s' is not available in nvim-lspconfig"):format(server_name), vim.log.levels.WARN)
        return
      end

      lspconfig[server_name].setup(merged_opts)
    end

    local function resolve_dotnet_cmd()
      local candidates = {
        vim.fn.exepath("dotnet"),
        "/usr/local/share/dotnet/dotnet",
        "/usr/local/bin/dotnet",
        "/opt/homebrew/bin/dotnet",
      }

      for _, cmd in ipairs(candidates) do
        if cmd and cmd ~= "" and vim.fn.executable(cmd) == 1 then
          return cmd
        end
      end

      return "dotnet"
    end

    -- mason-lspconfig v2 removed setup_handlers(); configure servers directly for compatibility.
    local common_servers = {
      resolve_typescript_server(),
      "html",
      "cssls",
      "tailwindcss",
      "prismals",
      "pyright",
    }

    for _, server_name in ipairs(common_servers) do
      setup_server(server_name)
    end

    -- configure svelte server
    setup_server("svelte", {
      on_attach = function(client, bufnr)
        vim.api.nvim_create_autocmd("BufWritePost", {
          pattern = { "*.js", "*.ts" },
          callback = function(ctx)
            -- Here use ctx.match instead of ctx.file
            client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
          end,
        })
      end,
    })

    -- configure graphql language server
    setup_server("graphql", {
      filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
    })

    -- configure emmet language server
    setup_server("emmet_ls", {
      filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
    })

    -- configure lua server (with special settings)
    setup_server("lua_ls", {
      settings = {
        Lua = {
          -- make the language server recognize "vim" global
          diagnostics = {
            globals = { "vim" },
          },
          completion = {
            callSnippet = "Replace",
          },
        },
      },
    })

    -- configure omnisharp with explicit dotnet resolution for GUI/limited PATH environments.
    setup_server("omnisharp", {
      cmd = {
        resolve_dotnet_cmd(),
        vim.fn.stdpath("data") .. "/mason/packages/omnisharp/libexec/OmniSharp.dll",
        "-z",
        "--hostPID",
        tostring(vim.fn.getpid()),
        "DotNet:enablePackageRestore=false",
        "--encoding",
        "utf-8",
        "--languageserver",
      },
      capabilities = {
        workspace = {
          workspaceFolders = false,
        },
      },
      settings = {
        RoslynExtensionsOptions = {
          EnableImportCompletion = true,
          EnableAnalyzersSupport = true,
          AnalyzeOpenDocumentsOnly = nil,
        },
      },
    })
  end,
}
