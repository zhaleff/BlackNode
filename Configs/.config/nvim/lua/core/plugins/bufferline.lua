return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "catppuccin/nvim",
    },
    event = "BufReadPost",
    config = function()
      require("bufferline").setup({
        options = {
          diagnostics = "nvim_lsp",
          diagnostics_indicator = function(count, level, diagnostics_dict, context)
            local icon = level:match("error") and " " or " "
            return " " .. icon .. count
          end,
          offsets = {
            {
              filetype = "neo-tree",
              text = "Explorer",
              text_align = "center",
              separator = true,
            },
          },
          separator_style = "thin",
          indicator = {
            style = "underline",
          },
          numbers = function(opts)
            return string.format("%s", opts.raise(opts.id))
          end,
          show_buffer_close_icons = true,
          show_close_icon = false,
          hover = {
            enabled = true,
            delay = 150,
            reveal = { "close" },
          },
          close_command = "bdelete! %d",
          right_mouse_command = "bdelete! %d",
          sort_by = "insert_after_current",
          mode = "buffers",
          color_icons = true,
          name_formatter = function(buf)
            if buf.name:match("%.md") then
              return vim.fn.fnamemodify(buf.name, ":t:r")
            end
          end,
          max_name_length = 18,
          max_prefix_length = 15,
          tab_size = 18,
          enforce_regular_tabs = false,
          always_show_bufferline = true,
        },
      })

      vim.api.nvim_create_autocmd("BufReadPost", {
        callback = function()
          vim.schedule(function()
            local exists, bufferline = pcall(require, "bufferline")
            if exists then
              pcall(bufferline, "refresh")
            end
          end)
        end,
      })

      vim.keymap.set("n", "<Tab>", function()
        require("bufferline").cycle(1)
      end, { desc = "Next tab" })

      vim.keymap.set("n", "<S-Tab>", function()
        require("bufferline").cycle(-1)
      end, { desc = "Previous tab" })

      require("catppuccin").setup({
        integrations = {
          bufferline = {
            enabled = true,
            highlight_inactive = false,
          },
        },
      })
    end,
  },
}