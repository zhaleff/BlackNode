return {
  "ibhagwan/fzf-lua",
  cmd = "FzfLua",
  keys = {
    {
      "<leader>fg",
      function()
        require("fzf-lua").live_grep()
      end,
      desc = "Grep in project",
    },
    {
      "<leader>fw",
      function()
        require("fzf-lua").grep_cword()
      end,
      desc = "Grep word under cursor",
    },
  },
  opts = {
    winopts = {
      height = 0.85,
      width = 0.80,
      preview = { layout = "vertical" },
    },
  },
}
