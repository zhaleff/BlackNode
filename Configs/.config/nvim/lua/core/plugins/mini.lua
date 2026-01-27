return {
  "echasnovski/mini.nvim",
  version = false,
  event = "VeryLazy",
  config = function()
    require("mini.surround").setup()
    require("mini.ai").setup()
  end,
}

