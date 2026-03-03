-- lazy.nvim
return {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {},
  dependencies = {
    "MunifTanjim/nui.nvim",
    {
      "rcarriga/nvim-notify",
      opts = {
        top_down = false,
        timeout = 1000,
      },
    },
  },
}
