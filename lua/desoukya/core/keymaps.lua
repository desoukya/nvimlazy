vim.g.mapleader = ","
-- code folding
vim.o.foldmethod = "indent"
vim.o.foldcolumn = "1"
vim.o.foldlevel = "20"
vim.o.foldnestmax = "1"
vim.o.foldlevelstart = "20"

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps
---------------------

-- enable folding
keymap.set("n", "<leader>fe", ":set foldenable<CR>") -- enable folding
keymap.set("n", "<leader>fd", ":set nofoldenable<CR>") -- enable folding

-- use jk to exit insert mode
keymap.set("i", "jk", "<ESC>")

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>")

-- delete single character without copying into register
keymap.set("n", "x", '"_x')

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>") -- increment
keymap.set("n", "<leader>-", "<C-x>") -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v") -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s") -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=") -- make split windows equal width & height
keymap.set("n", "<leader>sx", ":close<CR>") -- close current split window
-- vim-maximizer
keymap.set("n", "<leader>sm", ":MaximizerToggle<CR>") -- maximize a split window

keymap.set("n", "<leader>to", ":tabnew<CR>") -- open new tab
keymap.set("n", "<leader>tx", ":tabclose<CR>") -- close current tab
keymap.set("n", "<leader>tn", ":tabn<CR>") --  go to next tab
keymap.set("n", "<leader>tp", ":tabp<CR>") --  go to previous tab

-- save file
keymap.set("n", "<leader>s", ":w<CR>") -- save file
keymap.set("n", "<leader>wq", ":wq!<CR>") -- save and close file
keymap.set("n", "<leader>q", ":q!<CR>") -- close file
keymap.set("n", "<leader>qa", ":qa!<CR>") -- close all
keymap.set("n", "<leader>wa", ":wqa!<CR>") -- save and close all filles

----------------------
-- Plugin Keybinds
----------------------

-- nvim-tree
keymap.set("n", "<leader>b", ":NvimTreeToggle<CR>") -- toggle file explorer

-- telescope git commands (not on youtube nvim video)
keymap.set("n", "<leader>gc", "<cmd>Telescope git_commits<cr>") -- list all git commits (use <cr> to checkout) ["gc" for git commits]
keymap.set("n", "<leader>gfc", "<cmd>Telescope git_bcommits<cr>") -- list git commits for current file/buffer (use <cr> to checkout) ["gfc" for git file commits]
keymap.set("n", "<leader>gbr", "<cmd>Telescope git_branches<cr>") -- list git branches (use <cr> to checkout) ["gb" for git branch]

-- sort
keymap.set("v", "<leader>sl", ":Sort u<CR>") -- order lines
keymap.set("n", "<leader>si", ":TypescriptOrganizeImport<CR>") -- sort import statements

-- restart lsp server (not on youtube nvim video)
keymap.set("n", "<leader>rs", ":LspRestart<CR>") -- mapping to restart lsp if necessary

-- harpon
keymap.set("n", "<leader>hm", ":Telescope harpoon marks<cr>")

-- Lazy
keymap.set("n", "<leader>l", ":Lazy<cr>")
