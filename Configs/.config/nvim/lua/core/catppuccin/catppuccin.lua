return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      local status_ok, wallust = pcall(require, "core.wallust_colors")

      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
        term_colors = true,
        color_overrides = status_ok and {
          mocha = {
            base = wallust.background,
            mantle = wallust.color0,
            crust = wallust.color0,
            text = wallust.foreground,
            red = wallust.color9,
            green = wallust.color10,
            yellow = wallust.color11,
            blue = wallust.color12,
            magenta = wallust.color13,
            cyan = wallust.color14,
            surface0 = wallust.color8,
            surface1 = wallust.color7,
            surface2 = wallust.color15,
            mauve = wallust.color13,
            teal = wallust.color14,
          },
        } or {},
        custom_highlights = function(colors)
          return {
            CursorLine = { bg = colors.surface0 },
            CursorLineNr = { fg = colors.yellow, style = { "bold" } },
            Visual = { bg = colors.surface1, fg = colors.base },
            NormalFloat = { bg = colors.mantle },
            FloatBorder = { fg = colors.blue, bg = colors.mantle },
            
            -- cmp menu
            Pmenu = { bg = colors.mantle, fg = colors.text },
            PmenuSel = { bg = colors.blue, fg = colors.base, style = { "bold" } },
            PmenuSbar = { bg = colors.mantle },
            PmenuThumb = { bg = colors.surface1 },

            -- cmp items
            CmpItemAbbrDeprecated = { fg = colors.surface2, style = { "strikethrough" } },
            CmpItemAbbrMatch = { fg = colors.blue, style = { "bold" } },
            CmpItemAbbrMatchFuzzy = { fg = colors.cyan, style = { "bold" } },
            CmpItemKindVariable = { fg = colors.teal },
            CmpItemKindInterface = { fg = colors.teal },
            CmpItemKindText = { fg = colors.teal },
            CmpItemKindFunction = { fg = colors.magenta },
            CmpItemKindMethod = { fg = colors.magenta },
            CmpItemKindKeyword = { fg = colors.red, style = { "bold" } },
            CmpItemKindProperty = { fg = colors.red },
            CmpItemKindUnit = { fg = colors.red },
            
            Comment = { fg = colors.surface2, style = { "italic" } },
            LineNr = { fg = colors.surface1 },
          }
        end,
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          telescope = { enabled = true },
          treesitter = true,
          mason = true,
          native_lsp = { enabled = true },
        },
      })

      vim.cmd.colorscheme("catppuccin")

      local ctp_feline = require("catppuccin.special.feline")
      ctp_feline.setup({
        view = { lsp = { name = false } },
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
        components = ctp_feline.get_statusline(),
      })
    end,
  },
  {
    'feline-nvim/feline.nvim',
    lazy = true,
  },
}
