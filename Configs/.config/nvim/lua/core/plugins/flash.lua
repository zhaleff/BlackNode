return {
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      label = {
        uppercase = false,          
        rainbow = { enabled = true },
        after = false,                
        before = true,
        style = "inline",            
      },
      highlight = {
        backdrop = true, 
        matches = true,  
        groups = {
          match = "FlashMatch",
          current = "FlashCurrent",
          label = "FlashLabel",
          backdrop = "FlashBackdrop",
        },
      },
      modes = {
        search = {
          enabled = true, 
          incremental = true,
        },
        char = {
          enabled = true,          
          config = function(opts)
            opts.jump_labels = true       
          end,
          jump_labels = true,
          multi_line = true,
          search = { wrap = false },
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
        autojump = false, 
        inclusive = true,
      },
      prompt = {
        enabled = true,
        prefix = { { "⚡ ", "FlashPromptIcon" } },
      },
    },
    keys = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,                                                                             desc = "Flash Jump" },

      { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,                                                                       desc = "Flash Treesitter" },

      { "f",     mode = { "n", "x", "o" }, function() require("flash").jump({ search = { mode = "search", forward = true, wrap = false } }) end,               desc = "Flash f" },
      { "F",     mode = { "n", "x", "o" }, function() require("flash").jump({ search = { mode = "search", forward = false, wrap = false } }) end,              desc = "Flash F" },
      { "t",     mode = { "n", "x", "o" }, function() require("flash").jump({ search = { mode = "search", forward = true, wrap = false, till = true } }) end,  desc = "Flash t" },
      { "T",     mode = { "n", "x", "o" }, function() require("flash").jump({ search = { mode = "search", forward = false, wrap = false, till = true } }) end, desc = "Flash T" },

      { "r",     mode = "o",               function() require("flash").remote() end,                                                                           desc = "Remote Flash" },

      { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end,                                                                desc = "Treesitter Search" },

      { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,                                                                           desc = "Toggle Flash Search" },
    },
  },
}
