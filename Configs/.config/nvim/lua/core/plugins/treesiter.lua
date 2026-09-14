return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    main = "nvim-treesitter",
    opts = {
      ensure_installed = {
        "lua", "vim", "vimdoc", "query",
        "javascript", "typescript", "tsx",
        "html", "css", "scss",
        "json", "bash",
        "rust", "kotlin",
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "BufReadPost",
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = { ["]f"] = "@function.outer" },
          goto_previous_start = { ["[f"] = "@function.outer" },
        },
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    opts = {
      max_lines = 4,
      mode = "cursor",
      on_attach = function(buf)
        return vim.api.nvim_buf_line_count(buf) > 50
      end,
    },
  },
}
