return {
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- A clean, modern ASCII header that fits Catppuccin mocha perfectly
      -- Minimal cat silhouette – subtle, classy, not overwhelmin
      require("dashboard").setup({
        theme = "doom", -- Keeps the centred layout nice and clean
        config = {
          header = header,
          center = {
            {
              icon = "  ",
              desc = "Explorer            ",
              key = "e",
              action = "Neotree toggle",
            },
            {
              icon = "  ",
              desc = "Find Files          ",
              key = "f",
              action = "Telescope find_files",
            },
            {
              icon = "  ",
              desc = "Recent Files        ",
              key = "r",
              action = "Telescope oldfiles",
            },
            {
              icon = "󰈞  ",
              desc = "Live Grep           ",
              key = "g",
              action = "Telescope live_grep",
            },
            {
              icon = "󱐥  ",
              desc = "TODOs / Fixes       ",
              key = "t",
              action = "TodoTelescope",
            },
            {
              icon = "󰚰  ",
              desc = "Update Plugins      ",
              key = "u",
              action = "Lazy update",
            },
            {
              icon = "󰩈  ",
              desc = "Quit                ",
              key = "q",
              action = "qa",
            },
          },
          footer = function()
            local stats = require("lazy").stats()
            local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
            return {
              "",
              "  HyprCraft • " .. stats.loaded .. "/" .. stats.count .. " plugins •  " .. ms .. "ms",
              "",
            }
          end,
        },
      })
    end,
  },
}
