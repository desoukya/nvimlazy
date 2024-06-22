return {
  "carbon-steel/detour.nvim",
  config = function()
    vim.keymap.set("n", "<leader>dt", ":Detour<CR>") -- maximize a split window
    vim.keymap.set("n", "<leader>dtc", ":DetourCurrentWindow<CR>") -- maximize a split window
  end,
}
