return {
  {
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

      format_after_save = false,

      notify_on_error = true,
      notify_no_formatters = true,

      formatters_by_ft = {
        lua = { "stylua" },

        python = { "ruff_fix", "ruff_format", "black" },

        javascript = { "prettierd", "prettier" },
        typescript = { "prettierd", "prettier" },
        javascriptreact = { "prettierd", "prettier" },
        typescriptreact = { "prettierd", "prettier" },

        html = { "prettierd", "prettier" },
        css = { "prettierd", "prettier" },
        scss = { "prettierd", "prettier" },
        less = { "prettierd", "prettier" },
        json = { "prettierd", "prettier" },

        yaml = { "prettierd", "prettier" },
        markdown = { "prettierd", "prettier" },
        graphql = { "prettierd", "prettier" },

        blade = { "blade-formatter", "prettierd", "prettier" },
        php = { "pint", "prettierd", "prettier" },

        kotlin = { "ktlint" },

        ["_"] = { "trim_whitespace", "trim_newlines" },
      },

      formatters = {
        stylua = {
          prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
        },
        black = {
          prepend_args = { "--line-length", "100" },
        },
        prettier = {
          prepend_args = { "--single-quote", "--trailing-comma", "all" },
        },
        ["blade-formatter"] = {
          prepend_args = { "--indent-size", "2" },
        },
      },
    },
    config = function(_, opts)
      require("conform").setup(opts)
    end,
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    keys = {
      {
        "<leader>l",
        function()
          require("lint").try_lint()
        end,
        desc = "Trigger linting manual",
      },
    },
    opts = {
      linters_by_ft = {
        python = { "ruff" },
        lua = { "selene" },

        javascript = { "eslint" },
        typescript = { "eslint" },
        javascriptreact = { "eslint" },
        typescriptreact = { "eslint" },

        html = { "htmlhint" },
        css = { "stylelint" },
        scss = { "stylelint" },
      },

      linters = {
        ruff = {
          args = { "--format", "json", "--no-cache", "--stdin-filename", "$FILENAME" },
        },

        eslint = {
          condition = function(ctx)
            return vim.fs.find({ ".eslintrc", ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json" },
              { path = ctx.filename, upward = true })[1]
          end,
        },
      },
    },
    config = function(_, opts)
      local lint = require("lint")

      lint.linters_by_ft = opts.linters_by_ft

      for name, linter in pairs(opts.linters or {}) do
        if lint.linters[name] then
          lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
        end
      end

      local lint_augroup = vim.api.nvim_create_augroup("nvim-lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
