return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-tree/nvim-web-devicons",             -- Icons bonitos en resultados
      "nvim-telescope/telescope-ui-select.nvim", -- Usa Telescope para vim.ui.select (codeactions, etc.)
    },
    event = "VeryLazy",                          -- Carga cuando lo necesitas – startup más rápido
    keys = {
      -- Keymaps globales rápidos (aparecen en which-key si lo tienes)
      { "<leader>ff", "<cmd>Telescope find_files<CR>",            desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>",             desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>",               desc = "Buffers" },
      { "<leader>fo", "<cmd>Telescope oldfiles<CR>",              desc = "Recent Files" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>",             desc = "Help Tags" },
      { "<leader>fk", "<cmd>Telescope keymaps<CR>",               desc = "Keymaps" },
      { "<leader>fc", "<cmd>Telescope commands<CR>",              desc = "Commands" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>",  desc = "Document Symbols" },
      { "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<CR>", desc = "Workspace Symbols" },
      { "<leader>ft", "<cmd>TodoTelescope<CR>",                   desc = "TODOs/FIXMEs" },
      { "<leader>fr", "<cmd>Telescope resume<CR>",                desc = "Resume Last Search" },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local themes = require("telescope.themes")

      telescope.setup({
        defaults = {
          prompt_prefix = "   ",
          selection_caret = " ",
          entry_prefix = "  ",
          initial_mode = "insert",
          selection_strategy = "reset",
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
              results_width = 0.8,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          border = {},
          borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          color_devicons = true,
          path_display = { "truncate" },
          file_ignore_patterns = {
            "^.git/",
            "%.o$",
            "%.class$",
            "%.pdf$",
            "%.png$",
            "%.jpg$",
            "%.jpeg$",
            "%.lock$",
            "node_modules/",
            "%.DS_Store",
          },
          mappings = {
            i = {
              ["<C-n>"] = actions.cycle_history_next,
              ["<C-p>"] = actions.cycle_history_prev,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-c>"] = actions.close,
              ["<CR>"] = actions.select_default,
              ["<C-x>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,
              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-d>"] = actions.preview_scrolling_down,
              ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
              ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
            },
            n = {
              ["q"] = actions.close,
              ["j"] = actions.move_selection_next,
              ["k"] = actions.move_selection_previous,
              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-d>"] = actions.preview_scrolling_down,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            no_ignore = false,
            find_command = { "rg", "--files", "--hidden", "--glob=!.git/" },
          },
          live_grep = {
            additional_args = { "--hidden", "--glob=!.git/" },
          },
          buffers = {
            sort_mru = true,
            ignore_current_buffer = true,
            previewer = false,
          },
          oldfiles = {
            only_cwd = true,
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
          ["ui-select"] = {
            themes.get_dropdown({}),
          },
        },
      })

      -- Cargar extensions
      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")
    end,
  },
}
