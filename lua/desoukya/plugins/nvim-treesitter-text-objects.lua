-- nvim-treesitter `main` branch (the rewrite). The old `configs.setup` API and
-- its `master` branch are frozen and crash on Neovim 0.12.x when parsing
-- injected code blocks (e.g. ```json in markdown), which disables highlighting
-- globally. `main` is the version built for current Neovim.
--
-- Requires the `tree-sitter` CLI (brew install tree-sitter) to build parsers.

local PARSERS = {
  "lua",
  "vim",
  "vimdoc",
  "query",
  "graphql",
  "markdown",
  "markdown_inline",
  "javascript",
  "typescript",
  "tsx",
  "html",
  "css",
  "json",
  "hurl",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false, -- main does not support lazy-loading
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install(PARSERS)

      -- main does not auto-enable highlight/indent; start them per buffer for
      -- any filetype that has a parser installed.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          if pcall(vim.treesitter.start, ev.buf) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = {
          lookahead = true, -- jump forward to textobj, like targets.vim
        },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local swap = require("nvim-treesitter-textobjects.swap")
      local move = require("nvim-treesitter-textobjects.move")
      local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")

      -- Select (operator-pending + visual). @property.* comes from
      -- after/queries/ecma/textobjects.scm.
      local selects = {
        ["a="] = "@assignment.outer",
        ["i="] = "@assignment.inner",
        ["l="] = "@assignment.lhs",
        ["r="] = "@assignment.rhs",
        ["a:"] = "@property.outer",
        ["i:"] = "@property.inner",
        ["l:"] = "@property.lhs",
        ["r:"] = "@property.rhs",
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
        ["ai"] = "@conditional.outer",
        ["ii"] = "@conditional.inner",
        ["al"] = "@loop.outer",
        ["il"] = "@loop.inner",
        ["af"] = "@call.outer",
        ["if"] = "@call.inner",
        ["am"] = "@function.outer",
        ["im"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      }
      for lhs, query in pairs(selects) do
        vim.keymap.set({ "x", "o" }, lhs, function()
          select.select_textobject(query, "textobjects")
        end, { desc = "Select " .. query })
      end

      -- Swap
      vim.keymap.set("n", "<leader>na", function()
        swap.swap_next("@parameter.inner")
      end, { desc = "Swap next parameter/argument" })
      vim.keymap.set("n", "<leader>n:", function()
        swap.swap_next("@property.outer")
      end, { desc = "Swap next property" })
      vim.keymap.set("n", "<leader>nm", function()
        swap.swap_next("@function.outer")
      end, { desc = "Swap next function" })
      vim.keymap.set("n", "<leader>pa", function()
        swap.swap_previous("@parameter.inner")
      end, { desc = "Swap previous parameter/argument" })
      vim.keymap.set("n", "<leader>p:", function()
        swap.swap_previous("@property.outer")
      end, { desc = "Swap previous property" })
      vim.keymap.set("n", "<leader>pm", function()
        swap.swap_previous("@function.outer")
      end, { desc = "Swap previous function" })

      -- Move
      local moves = {
        goto_next_start = {
          ["]f"] = { "@call.outer", "textobjects" },
          ["]m"] = { "@function.outer", "textobjects" },
          ["]c"] = { "@class.outer", "textobjects" },
          ["]i"] = { "@conditional.outer", "textobjects" },
          ["]l"] = { "@loop.outer", "textobjects" },
          ["]s"] = { "@local.scope", "locals" },
          ["]z"] = { "@fold", "folds" },
        },
        goto_next_end = {
          ["]F"] = { "@call.outer", "textobjects" },
          ["]M"] = { "@function.outer", "textobjects" },
          ["]C"] = { "@class.outer", "textobjects" },
          ["]I"] = { "@conditional.outer", "textobjects" },
          ["]L"] = { "@loop.outer", "textobjects" },
        },
        goto_previous_start = {
          ["[f"] = { "@call.outer", "textobjects" },
          ["[m"] = { "@function.outer", "textobjects" },
          ["[c"] = { "@class.outer", "textobjects" },
          ["[i"] = { "@conditional.outer", "textobjects" },
          ["[l"] = { "@loop.outer", "textobjects" },
        },
        goto_previous_end = {
          ["[F"] = { "@call.outer", "textobjects" },
          ["[M"] = { "@function.outer", "textobjects" },
          ["[C"] = { "@class.outer", "textobjects" },
          ["[I"] = { "@conditional.outer", "textobjects" },
          ["[L"] = { "@loop.outer", "textobjects" },
        },
      }
      for fn, maps in pairs(moves) do
        for lhs, spec in pairs(maps) do
          vim.keymap.set({ "n", "x", "o" }, lhs, function()
            move[fn](spec[1], spec[2])
          end, { desc = fn:gsub("_", " ") .. " " .. spec[1] })
        end
      end

      -- Repeatable moves. NOTE: <leader> is ",", so only ";" is mapped (not ",").
      vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
      vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })
    end,
  },
}
