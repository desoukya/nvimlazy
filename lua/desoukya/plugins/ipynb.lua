-- Jupyter notebooks as visual cell blocks (ajbucci/ipynb.nvim — modal notebook
-- editor). Attaches to .ipynb files automatically.
--
-- ALPHA: expect rough edges.
--
-- Execution needs `jupyter_client` + `ipykernel` in the kernel's Python.
-- ipynb.nvim's discovery order: :NotebookKernelStart arg → kernel.python_path →
-- a project venv (.venv/venv/… walking up) → system python. So for a project
-- notebook, `pip install jupyter_client ipykernel` in that project's venv.
--
-- Inline images/plots need `snacks.nvim` + a Kitty-graphics-protocol terminal
-- (kitty/Ghostty) + tmux allow-passthrough. On iTerm2 plots show
-- "[Image failed to load]", but cell blocks and text outputs work fine.
return {
  "ajbucci/ipynb.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "neovim/nvim-lspconfig",
    "nvim-tree/nvim-web-devicons",
    -- "folke/snacks.nvim", -- enable for inline images (needs kitty/Ghostty)
  },
  -- ipynb.nvim's own `ipynb` treesitter parser auto-install targets the OLD
  -- nvim-treesitter API, which doesn't exist on the `main` branch we use — so
  -- compile it ourselves (with the tree-sitter CLI) into site/parser, where
  -- Neovim finds it. Runs on install and `:Lazy build ipynb.nvim`.
  build = function(plugin)
    local src = plugin.dir .. "/tree-sitter-ipynb"
    local out = vim.fn.stdpath("data") .. "/site/parser/ipynb.so"
    vim.fn.mkdir(vim.fn.fnamemodify(out, ":h"), "p")
    vim.fn.system("cd " .. vim.fn.shellescape(src) .. " && tree-sitter build -o " .. vim.fn.shellescape(out))
  end,
  opts = {
    -- reversed from defaults: <leader>kx = execute & next, <leader>kX = execute cell
    keymaps = {
      menu_execute_cell = "<leader>kX",
      menu_execute_and_next = "<leader>kx",
    },
  },
}
