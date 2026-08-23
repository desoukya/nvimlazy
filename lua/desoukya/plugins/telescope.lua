return {
  "nvim-telescope/telescope.nvim",
  -- master (not 0.1.x): 0.1.x is frozen and uses the removed nvim-treesitter
  -- `configs`/`parsers` API, which errors under treesitter `main`. master uses
  -- core vim.treesitter for preview highlighting.
  branch = "master",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      config = function()
        require("telescope").load_extension("fzf")
      end,
    },
    "nvim-tree/nvim-web-devicons",
    "folke/todo-comments.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local transform_mod = require("telescope.actions.mt").transform_mod

    local trouble = require("trouble")
    local trouble_telescope = require("trouble.sources.telescope")

    -- or create your custom action
    local custom_actions = transform_mod({
      open_trouble_qflist = function(prompt_bufnr)
        trouble.toggle("quickfix")
      end,
    })

    telescope.setup({
      defaults = {
        file_ignore_patterns = {
          "node_modules",
          ".obsidian",
          ".DS_Store",
          ".git",
          ".yarn",
          ".husky",
          "yarn.lock",
          "e2e",
          "%.spec.ts",
          "%.spec.js",
        },
        path_display = { "smart" },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous, -- move to prev result
            ["<C-j>"] = actions.move_selection_next, -- move to next result
            ["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
            ["<C-t>"] = trouble_telescope.open,
          },
        },
      },
      pickers = {
        live_grep = {
          additional_args = { "--hidden" },
        },
        grep_string = {
          additional_args = { "--hidden" },
        },
        find_files = {
          -- theme = "dropdown",
          hidden = true,
        },
      },
    })

    telescope.load_extension("fzf")

    -- set keymaps
    local keymap = vim.keymap -- for conciseness

    keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
    keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
    keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
    -- live grep pre-seeded with the word under the cursor (normal) or the
    -- visual selection — shows results instantly and stays refinable
    keymap.set("n", "<leader>fc", function()
      require("telescope.builtin").live_grep({ default_text = vim.fn.expand("<cword>") })
    end, { desc = "Live grep word under cursor" })
    keymap.set("x", "<leader>fc", function()
      local region = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
      require("telescope.builtin").live_grep({ default_text = table.concat(region, " ") })
    end, { desc = "Live grep selection" })
    keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
  end,
}
