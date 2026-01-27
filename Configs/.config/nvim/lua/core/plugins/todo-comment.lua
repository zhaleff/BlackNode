return {
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPost", "BufNewFile" }, -- Carga cuando abres archivos (ágil)
    keys = {
      { "]t",         function() require("todo-comments").jump_next() end, desc = "Next TODO" },
      { "[t",         function() require("todo-comments").jump_prev() end, desc = "Prev TODO" },
      { "<leader>ft", "<cmd>TodoTelescope<CR>",                            desc = "Find TODOs (Telescope)" },
    },
    opts = {
      signs = true, -- Muestra icons en la gutter (columna de signs)
      sign_priority = 8,
      keywords = {
        FIX = { icon = " ", color = "error" }, -- FIXME, FIX, BUG
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning" },
        PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
      gui_style = {
        fg = "NONE",
        bg = "BOLD",
      },
      highlight = {
        multiline = true,
        multiline_pattern = "^.", -- Detecta TODOs multilínea
        multiline_context = 10,
        before = "",
        keyword = "wide",
        after = "fg",
        pattern = [[.*<(KEYWORDS)\s*(\([^\)]*\))?:]], -- Soporta TODO(author): mensaje
        comments_only = true,
        max_line_len = 400,
        exclude = {},
      },
      search = {
        command = "rg",
        args = {
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
        },
        pattern = [[\b(KEYWORDS)(\([^\)]*\))?:]],
      },
    },
  },
}
