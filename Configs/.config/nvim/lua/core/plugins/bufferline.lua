return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
          diagnostics = "nvim_lsp",
          offsets = { { filetype = "NvimTree", text = "Explorer", padding = 1 } },
          separator_style = "thin",
          indicator = { style = "underline" },
          hover = { enabled = true, delay = 200, reveal = { "close" } },
        },
      })
    end,
  },
}
