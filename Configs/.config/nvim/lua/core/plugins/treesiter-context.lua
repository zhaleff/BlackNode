return {
  "nvim-treesitter/nvim-treesitter-context",
  event = "BufReadPost",
  opts = {
    enable = true,
    max_lines = 3,
    trim_scope = "outer",
    mode = "cursor",
    separator = nil,
  },
}

