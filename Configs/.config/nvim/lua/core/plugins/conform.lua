return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>f",
      function()
        require("conform").format({ async = true, lsp_fallback = true, timeout_ms = 1000 })
      end,
      mode = { "n", "v" },
      desc = "Format buffer or selection",
    },
  },
  opts = {
    format_on_save = {
      timeout_ms = 800,
      lsp_fallback = true,
      async = false,
    },

    notify_on_error = true,
    notify_no_formatters = true,

    formatters_by_ft = {
      lua = { "stylua" },

      javascript = { "prettierd", "prettier" },
      typescript = { "prettierd", "prettier" },
      javascriptreact = { "prettierd", "prettier" },
      typescriptreact = { "prettierd", "prettier" },

      html = { "prettierd", "prettier" },
      css = { "prettierd", "prettier" },
      scss = { "prettierd", "prettier" },
      json = { "prettierd", "prettier" },

      kotlin = { "ktlint" },

      ["_"] = { "trim_whitespace", "trim_newlines" },
    },

    formatters = {
      stylua = {
        prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
      },
      prettier = {
        prepend_args = { "--single-quote", "--trailing-comma", "all" },
      },
    },
  },
}
