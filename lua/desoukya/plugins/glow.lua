return {
  "ellisonleao/glow.nvim",
  ft = { "markdown" },
  cmd = { "Glow" },
  config = function()
    if vim.fn.executable("glow") == 0 then
      vim.notify("Missing `glow` binary. Install with: brew install glow", vim.log.levels.WARN)
    end

    require("glow").setup({
      border = "single",
      width_ratio = 0.63,
      -- glow.nvim's default `width=100` caps the ratio-based width and (due to
      -- how it computes `col`) makes the window look left-shifted.
      width = 999,
    })

    vim.keymap.set("n", "<leader>md", "<cmd>Glow<cr>", { desc = "Markdown preview (glow)" })
  end,
}
