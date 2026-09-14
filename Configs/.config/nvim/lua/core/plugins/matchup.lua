return {
  "andymass/vim-matchup",
  event = { "BufReadPost", "BufNewFile" },
  init = function()
    vim.g.matchup_matchparen_offscreen = { method = "popup" }
  end,
}
