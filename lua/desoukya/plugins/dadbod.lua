return {
  "kristijanhusak/vim-dadbod-ui",
  dependencies = {
    { "tpope/vim-dadbod", lazy = true },
    { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
  },
  cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
  keys = {
    { "<leader>db", "<cmd>DBUIToggle<cr>", desc = "Toggle DB UI" },
  },
  init = function()
    -- vim-dadbod-ui reads these globals at startup (it's a vimscript plugin, no setup())
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_show_database_icon = 1
    vim.g.db_ui_win_position = "left"
    vim.g.db_ui_winwidth = 30

    -- SQL autocomplete through your existing nvim-cmp (buffer-local for DB buffers)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "sql", "mysql", "plsql" },
      callback = function()
        local ok, cmp = pcall(require, "cmp")
        if ok then
          cmp.setup.buffer({
            sources = {
              { name = "vim-dadbod-completion" },
              { name = "buffer" },
              { name = "luasnip" },
            },
          })
        end

        -- Run only the query under the cursor (current paragraph) instead of the
        -- whole buffer. <Leader>S still runs everything; separate queries with a
        -- blank line so the paragraph select grabs exactly one.
        vim.keymap.set("n", "<leader>rq", "vip<Plug>(DBUI_ExecuteQuery)", {
          buffer = true,
          remap = true,
          silent = true,
          desc = "DB: run query under cursor",
        })
      end,
    })
  end,
}
