return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  config = function()
    local colors = require("core.highlights.colors")

    local function mode(bg)
      return {
        a = { fg = colors.bg, bg = bg, gui = "bold" },
        b = { fg = colors.fg, bg = colors.surface },
        c = { fg = colors.on_surface_variant, bg = colors.bg },
      }
    end

    local theme = {
      normal = mode(colors.primary),
      insert = mode(colors.tertiary),
      visual = mode(colors.secondary),
      replace = mode(colors.error),
      command = mode(colors.primary),
      terminal = mode(colors.tertiary_container),
      inactive = {
        a = { fg = colors.outline, bg = colors.bg },
        b = { fg = colors.outline, bg = colors.bg },
        c = { fg = colors.outline, bg = colors.bg },
      },
    }

    require("lualine").setup({
      options = {
        theme = theme,
        component_separators = "",
        section_separators = "",
        globalstatus = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "diagnostics", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    })
  end,
}
