return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
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
          neo_tree = true,
          trouble = true,
          nvimtree = true,
          telescope = { enabled = true },
          treesitter = true,
          dashboard = true,
          which_key = true,
          notify = true,
          mason = true,
          flash = true,
          treesitter_context = true,
          todo_comments = true,
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

      -- Feline
      local ctp_feline = require("catppuccin.special.feline")

      ctp_feline.setup({
        view = {
          lsp = {
            name = false,
          },
        },
        assets = {
          lsp = {
            server = "󰅡",
            error = "",
            warning = "",
            info = "󰋼",
            hint = "󰛩",
          },
        },
      })
      require("feline").setup({
        disable = {
          filetypes = {},
          buftypes = {},
        },
        components = ctp_feline.get_statusline(),
      })
    end,
  },
  {
    'feline-nvim/feline.nvim',
    lazy = true,
  },
}
