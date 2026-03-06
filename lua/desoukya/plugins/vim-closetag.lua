return {
  "alvan/vim-closetag",
  ft = { "html" },
  init = function()
    vim.g.closetag_filenames = "*.html,*.htm"
    vim.g.closetag_xhtml_filenames = "*.xhtml"
    vim.g.closetag_filetypes = "html"
  end,
}
