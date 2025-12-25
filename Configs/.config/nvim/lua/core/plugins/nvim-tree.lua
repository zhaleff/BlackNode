return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 35, side = "left", adaptive_size = true },
        renderer = {
          group_empty = true,
          highlight_git = true,
          icons = { show = { file = true, folder = true, folder_arrow = true, git = true } },
        },
        filters = { dotfiles = true, custom = { "^.git$" } },
        git = { enable = true, ignore = false },
        update_focused_file = { enable = true, update_root = false },
      })
    end,
  },
}
