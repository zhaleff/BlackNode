return {
  {
    "rcarriga/nvim-notify",
    config = function()
      vim.notify = require("notify")
      require("notify").setup({
        timeout = 3000,
        max_height = function() return math.floor(vim.o.lines * 0.40) end,
        max_width = function() return math.floor(vim.o.columns * 0.40) end,
      })
    end,
  },
}
