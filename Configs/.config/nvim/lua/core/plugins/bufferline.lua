return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = { "BufReadPre", "BufNewFile" }, -- Loads when you open files – nice and quick
    config = function()
      require("bufferline").setup({
        options = {
          -- Diagnostics from LSP – shows error/warning counts beautifully
          diagnostics = "nvim_lsp",
          diagnostics_indicator = function(count, level, diagnostics_dict, context)
            local icon = level:match("error") and " " or " "
            return " " .. icon .. count
          end,

          -- Offset for Neo-tree (your current explorer)
          offsets = {
            {
              filetype = "neo-tree",
              text = "Explorer",
              text_align = "center",
              separator = true,
            },
          },

          -- Visual style – thin separators, underline for active tab
          separator_style = "thin",
          indicator = {
            style = "underline",
          },

          -- Buffer numbers with icons (looks classy with nerdfont)
          numbers = function(opts)
            return string.format("%s", opts.raise(opts.id))
          end,

          -- Close button on each tab
          show_buffer_close_icons = true,
          show_close_icon = false, -- No big close on the right end

          -- Hover effects – subtle but useful
          hover = {
            enabled = true,
            delay = 150,
            reveal = { "close" },
          },

          -- Click to close buffer (middle click)
          close_command = "bdelete! %d",
          right_mouse_command = "bdelete! %d",

          -- Sort buffers by directory then extension – keeps things tidy
          sort_by = "insert_after_current",

          -- Highlights integration with Catppuccin (pulls colours automatically)

          -- Mode-specific colours (changes tab colour based on vi mode)
          mode = "buffers", -- or "tabs" if you prefer
          color_icons = true,

          -- Truncate long names nicely
          name_formatter = function(buf)
            if buf.name:match("%.md") then
              return vim.fn.fnamemodify(buf.name, ":t:r")
            end
          end,

          -- Max name length
          max_name_length = 18,
          max_prefix_length = 15,
          tab_size = 18,

          enforce_regular_tabs = false,
          always_show_bufferline = true,
        },
      })
    end,
  },
}
