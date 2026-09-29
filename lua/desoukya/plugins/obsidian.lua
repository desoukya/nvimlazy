return {
  {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    -- Only load when the vault exists; otherwise obsidian throws
    -- FileNotFoundError on ANY markdown buffer (e.g. a Hurl response).
    cond = function()
      return vim.fn.isdirectory(vim.fn.expand("~/dev/vault")) == 1
    end,
    dependencies = {
      -- Required.
      "nvim-lua/plenary.nvim",
    },
    opts = {
      workspaces = {
        {
          name = "vault",
          path = "~/dev/vault",
        },
      },
      -- ui = { enable = false },
    },
    -- mappings = {
    --   ["gf"] = {
    --     action = function()
    --       return require("obsidian").util.gf_passthrough()
    --     end,
    --     opts = { noremap = false, expr = true, buffer = true },
    --   },
    -- },
  },
  -- pretty markdown
  {
    "MeanderingProgrammer/render-markdown.nvim",
    enabled = false, -- (was `enable = false`, a typo — lazy's key is `enabled`).
    -- It links code blocks to ColorColumn (a solid bg), which showed as a black
    -- block behind Hurl's ```json responses once treesitter `main` let it render.
    opts = {},
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
  },

  -- markdown preview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install",
    keys = {},
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },
}
