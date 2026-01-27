return {
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      -- Labels más visibles y bonitos (se ven brutal con Catppuccin)
      label = {
        uppercase = false,            -- letras minúsculas (más fáciles de leer rápido)
        rainbow = { enabled = true }, -- Colores arcoíris para distinguir labels
        after = false,                -- Labels después del match (mejor flujo visual)
        before = true,
        style = "inline",             -- Inline para no tapar texto
      },
      highlight = {
        backdrop = true, -- Fondo sutil para enfocar (pero no molesto)
        matches = true,  -- Resalta todos los matches
        groups = {
          match = "FlashMatch",
          current = "FlashCurrent",
          label = "FlashLabel",
          backdrop = "FlashBackdrop",
        },
      },
      modes = {
        search = {
          enabled = true, -- Integra PERFECTO con / y ? (flash activa labels en búsquedas normales)
          incremental = true,
        },
        char = {
          enabled = true,           -- Mejora f/t/F/T con labels (mucho más rápido y preciso)
          config = function(opts)
            opts.jump_labels = true -- Siempre labels en f/t
          end,
          jump_labels = true,
          multi_line = true,
          search = { wrap = false }, -- No wrap en f/t para precisión
          highlight = { backdrop = false },
        },
        treesitter = {
          enabled = true,
          jump = { pos = "range" },
        },
        treesitter_search = {
          enabled = true,
        },
        remote = {
          enabled = true,
        },
      },
      jump = {
        autojump = false, -- Desactiva autojump para más control (te obliga a presionar label, pero es más preciso)
        inclusive = true,
      },
      prompt = {
        enabled = true,
        prefix = { { "⚡ ", "FlashPromptIcon" } },
      },
    },
    keys = {
      -- Básico: s + 2 chars → jump con labels
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,                                                                             desc = "Flash Jump" },

      -- Treesitter: selecciona bloques inteligentes (funciones, clases, if, etc.)
      { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,                                                                       desc = "Flash Treesitter" },

      -- Mejora f/t/F/T nativos con labels (BRUTAL para moverse en línea)
      { "f",     mode = { "n", "x", "o" }, function() require("flash").jump({ search = { mode = "search", forward = true, wrap = false } }) end,               desc = "Flash f" },
      { "F",     mode = { "n", "x", "o" }, function() require("flash").jump({ search = { mode = "search", forward = false, wrap = false } }) end,              desc = "Flash F" },
      { "t",     mode = { "n", "x", "o" }, function() require("flash").jump({ search = { mode = "search", forward = true, wrap = false, till = true } }) end,  desc = "Flash t" },
      { "T",     mode = { "n", "x", "o" }, function() require("flash").jump({ search = { mode = "search", forward = false, wrap = false, till = true } }) end, desc = "Flash T" },

      -- Remote (para operadores: ds, cs, ys, etc.)
      { "r",     mode = "o",               function() require("flash").remote() end,                                                                           desc = "Remote Flash" },

      -- Treesitter search (busca dentro de bloques)
      { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end,                                                                desc = "Treesitter Search" },

      -- Toggle flash en búsquedas normales (/ ?)
      { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,                                                                           desc = "Toggle Flash Search" },
    },
  },
}
