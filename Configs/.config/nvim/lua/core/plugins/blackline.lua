return {
  "echasnovski/mini.indentscope",
  version = false, 
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    draw = {
      delay = 0, 
      priority = 2,
    },
    symbol = "│", 
    options = {
      border = "both",
      indent_at_cursor = true,
      try_as_border = true,  
    },
  },
  config = function(_, opts)
    require("mini.indentscope").setup(opts)

    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "help",
        "alpha",
        "dashboard",
        "neo-tree",
        "Trouble",
        "trouble",
        "lazy",
        "mason",
        "notify",
        "toggleterm",
        "lazyterm",
        "fzf",
        "telescope",
        "nvim-tree",
      },
      callback = function()
        vim.b.miniindentscope_disable = true
      end,
    })
  end,
}
