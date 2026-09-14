-- lua/plugins/bufferline.lua

local colors = require("core.highlights.colors")

return {
  "akinsho/bufferline.nvim",
  version = "*",
  event = "VeryLazy",
  dependencies = "nvim-tree/nvim-web-devicons",
  opts = {
    options = {
      mode = "buffers",
      separator_style = "thin",
      always_show_bufferline = true,
      diagnostics = "nvim_lsp",
    },
    highlights = {
      fill = { bg = colors.surface_dim },
      background = { fg = colors.outline, bg = colors.surface_dim },

      buffer_selected = { fg = colors.on_surface, bg = colors.surface, bold = true },
      buffer_visible = { fg = colors.outline, bg = colors.surface_dim },

      indicator_selected = { fg = colors.primary, bg = colors.surface },

      modified = { fg = colors.secondary, bg = colors.surface_dim },
      modified_selected = { fg = colors.secondary, bg = colors.surface },

      separator = { fg = colors.surface_dim, bg = colors.surface_dim },
      separator_selected = { fg = colors.surface_dim, bg = colors.surface },

      error = { fg = colors.error, bg = colors.surface_dim },
      error_selected = { fg = colors.error, bg = colors.surface },

      close_button = { fg = colors.outline, bg = colors.surface_dim },
      close_button_visible = { fg = colors.outline, bg = colors.surface_dim },
      close_button_selected = { fg = colors.on_surface, bg = colors.surface },
    },
  },
}
