return {
  "rmagatti/goto-preview",
  event = "BufEnter",
  config = true,
  keys = {
    {
      "gd",
      "<cmd>lua require('goto-preview').goto_preview_definition()<CR>",
      noremap = true,
      desc = "goto preview definition",
    },
    {
      "gD",
      "<cmd>lua require('goto-preview').goto_preview_declaration()<CR>",
      noremap = true,
      desc = "goto preview declaration",
    },
    {
      "gi",
      "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>",
      noremap = true,
      desc = "goto preview implementation",
    },
    {
      "gy",
      "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>",
      noremap = true,
      desc = "goto preview type definition",
    },
    {
      "gf",
      "<cmd>lua require('goto-preview').goto_preview_references()<CR>",
      noremap = true,
      desc = "goto preview references",
    },
    {
      "gq",
      "<cmd>lua require('goto-preview').close_all_win()<CR>",
      noremap = true,
      desc = "close all preview windows",
    },
  },
}
