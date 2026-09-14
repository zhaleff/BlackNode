return {
  "stevearc/oil.nvim",
  cmd = "Oil",
  keys = {
    {
      "<leader>e",
      function()
        require("oil").open_float()
      end,
      desc = "Explorer (oil, float)",
    },
  },
  opts = {
    default_file_explorer = true,
    view_options = { show_hidden = true },
    float = {
      padding = 4,
      max_width = 90,
      max_height = 30,
      border = "rounded",
    },
    keymaps = {
      ["<C-c>"] = false,
      ["q"] = "actions.close",
    },
  },
}
