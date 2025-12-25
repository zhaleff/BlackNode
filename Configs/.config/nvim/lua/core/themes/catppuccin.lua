return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000, -- Se carga primero
    config = function()
      -- 1. PRIMERO configurar Catppuccin
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
        show_end_of_buffer = false,
        term_colors = true,
        dim_inactive = { enabled = true, percentage = 0.15 },
        styles = {
          comments = { "italic" },
          functions = { "bold" },
          keywords = { "italic" },
          variables = { "italic" },
        },
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          telescope = { enabled = true },
          treesitter = true,
          dashboard = true,
          which_key = true,
          notify = true,
          bufferline = true,
          indent_blankline = { enabled = true, scope_color = "mauve" },
          mini = { enabled = true },
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = { "italic" },
              hints = { "italic" },
              warnings = { "italic" },
              information = { "italic" },
            },
            underlines = {
              errors = { "underline" },
              hints = { "undercurl" },
              warnings = { "underline" },
              information = { "underline" },
            },
          },
        },
      })
      vim.cmd.colorscheme("catppuccin")    
      
      local ctp_feline = require('catppuccin.special.feline')
      ctp_feline.setup()       
      require("feline").setup({
        components = ctp_feline.get_statusline(),
      })
    end,
  },
  
  {
    'feline-nvim/feline.nvim',
    lazy = true,   },
}
