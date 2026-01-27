return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x", -- asegúrate de usar la versión estable
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- íconos
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        popup_border_style = "rounded",
        enable_git_status = true,
        enable_diagnostics = true,
        default_component_configs = {
          icon = {
            folder_closed = "",
            folder_open = "",
            folder_empty = "ﰊ",
          },
          git_status = {
            symbols = {
              added = "",
              modified = "柳",
              deleted = "",
            },
          },
        },
        window = {
          width = 35,
          position = "left",
          mappings = {
            ["<space>"] = "toggle_node",
            ["<cr>"] = "open",
            ["S"] = "open_split",
            ["s"] = "open_vsplit",
            ["d"] = "delete",
          },
        },
        filesystem = {
          filtered_items = {
            hide_dotfiles = true,
            hide_gitignored = false,
          },
          follow_current_file = true,
          group_empty_dirs = true,
        },
      })
    end,
  },
}

