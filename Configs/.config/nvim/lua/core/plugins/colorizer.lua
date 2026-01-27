return {
  "norcalli/nvim-colorizer.lua",
  event = "BufReadPre",
  config = function()
    require("colorizer").setup({
      "*",                     -- todos los filetypes
      css = { rgb_fn = true }, -- rgb(), hsl(), etc
      html = { names = true },
      lua = { names = false },
    }, {
      mode = "background", -- o "foreground"
      RGB = true,
      RRGGBB = true,
      RRGGBBAA = true,
      AARRGGBB = true,
      rgb_fn = true,
      hsl_fn = true,
      names = true,
      tailwind = true,
    })
  end,
}
