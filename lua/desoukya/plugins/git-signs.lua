return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
      end

      -- Navigation
      map("n", "]h", gs.next_hunk, "Next Hunk")
      map("n", "[h", gs.prev_hunk, "Prev Hunk")

      -- Actions
      map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
      map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
      map("v", "<leader>hs", function()
        gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Stage hunk")
      map("v", "<leader>hr", function()
        gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Reset hunk")

      map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
      map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")

      map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")

      map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")

      -- Review mode: highlight changed lines red/green in the buffer
      map("n", "<leader>ht", gs.toggle_linehl, "Toggle line highlight (diff)")
      map("n", "<leader>hw", gs.toggle_word_diff, "Toggle word diff")
      map("n", "<leader>hx", gs.toggle_deleted, "Toggle deleted lines (inline)")
      -- Review view: line highlight + word diff + inline deleted, all at once
      map("n", "<leader>hv", function()
        gs.toggle_linehl()
        gs.toggle_word_diff()
        gs.toggle_deleted()
      end, "Toggle review view (line + word diff + deleted)")

      map("n", "<leader>hb", function()
        gs.blame_line({ full = true })
      end, "Blame line")
      map("n", "<leader>hB", gs.toggle_current_line_blame, "Toggle line blame")

      map("n", "<leader>hd", gs.diffthis, "Diff this")
      map("n", "<leader>hD", function()
        gs.diffthis("~")
      end, "Diff this ~")

      -- Text object
      map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Gitsigns select hunk")
    end,
  },
  config = function(_, opts)
    require("gitsigns").setup(opts)

    -- More pronounced red/green diff highlights (used by <leader>ht / <leader>hw / <leader>hx)
    local function set_diff_hl()
      -- whole-line highlights (linehl)
      vim.api.nvim_set_hl(0, "GitSignsAddLn", { bg = "#163f24" })
      vim.api.nvim_set_hl(0, "GitSignsChangeLn", { bg = "#2c3860" })
      vim.api.nvim_set_hl(0, "GitSignsDeleteLn", { bg = "#4f2027" })
      -- intra-line highlights (word_diff)
      vim.api.nvim_set_hl(0, "GitSignsAddInline", { bg = "#245e3c" })
      vim.api.nvim_set_hl(0, "GitSignsChangeInline", { bg = "#3a4880" })
      vim.api.nvim_set_hl(0, "GitSignsDeleteInline", { bg = "#782c34" })
      -- deleted lines shown inline (toggle_deleted)
      vim.api.nvim_set_hl(0, "GitSignsDeleteVirtLn", { bg = "#4f2027" })
    end

    set_diff_hl()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = set_diff_hl })
  end,
}
