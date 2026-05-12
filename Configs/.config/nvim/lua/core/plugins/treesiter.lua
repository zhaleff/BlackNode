return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build  = ":TSUpdate",
    event  = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    main = "nvim-treesitter",
    opts = {
      ensure_installed = {
        "lua", "luadoc", "vim", "vimdoc", "query",
        "javascript", "typescript", "tsx",
        "html", "css", "scss",
        "vue", "svelte", "astro",
        "json", "jsonc", "yaml", "sql",
        "markdown", "markdown_inline",
        "bash", "regex",
        "gitignore", "gitcommit",
      },
      highlight = { enable = true, additional_vim_regex_highlighting = false },
      indent    = { enable = true },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    lazy   = true,
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = {
          enable    = true,
          lookahead = true,
          keymaps   = {
            ["af"] = { query = "@function.outer",    desc = "Función outer"    },
            ["if"] = { query = "@function.inner",    desc = "Función inner"    },
            ["ac"] = { query = "@class.outer",       desc = "Clase outer"      },
            ["ic"] = { query = "@class.inner",       desc = "Clase inner"      },
            ["aa"] = { query = "@parameter.outer",   desc = "Argumento outer"  },
            ["ia"] = { query = "@parameter.inner",   desc = "Argumento inner"  },
            ["ab"] = { query = "@block.outer",       desc = "Bloque outer"     },
            ["ib"] = { query = "@block.inner",       desc = "Bloque inner"     },
            ["al"] = { query = "@loop.outer",        desc = "Loop outer"       },
            ["il"] = { query = "@loop.inner",        desc = "Loop inner"       },
            ["ai"] = { query = "@conditional.outer", desc = "Condicional outer"},
            ["ii"] = { query = "@conditional.inner", desc = "Condicional inner"},
            ["as"] = { query = "@statement.outer",   desc = "Statement"        },
            ["am"] = { query = "@call.outer",        desc = "Llamada outer"    },
            ["im"] = { query = "@call.inner",        desc = "Llamada inner"    },
          },
          selection_modes = {
            ["@function.outer"]    = "V",
            ["@class.outer"]       = "V",
            ["@block.outer"]       = "V",
            ["@statement.outer"]   = "V",
          },
          include_surrounding_whitespace = false,
        },

        move = {
          enable     = true,
          set_jumps  = true,
          goto_next_start = {
            ["]f"] = { query = "@function.outer", desc = "Siguiente función" },
            ["]c"] = { query = "@class.outer",    desc = "Siguiente clase"   },
            ["]a"] = { query = "@parameter.inner",desc = "Siguiente argumento"},
            ["]b"] = { query = "@block.outer",    desc = "Siguiente bloque"  },
            ["]l"] = { query = "@loop.outer",     desc = "Siguiente loop"    },
          },
          goto_next_end = {
            ["]F"] = { query = "@function.outer", desc = "Fin siguiente función"},
            ["]C"] = { query = "@class.outer",    desc = "Fin siguiente clase"  },
          },
          goto_previous_start = {
            ["[f"] = { query = "@function.outer", desc = "Función anterior"  },
            ["[c"] = { query = "@class.outer",    desc = "Clase anterior"    },
            ["[a"] = { query = "@parameter.inner",desc = "Argumento anterior"},
            ["[b"] = { query = "@block.outer",    desc = "Bloque anterior"   },
            ["[l"] = { query = "@loop.outer",     desc = "Loop anterior"     },
          },
          goto_previous_end = {
            ["[F"] = { query = "@function.outer", desc = "Fin función anterior"},
            ["[C"] = { query = "@class.outer",    desc = "Fin clase anterior"  },
          },
        },

        swap = {
          enable        = true,
          swap_next     = {
            ["<leader>sa"] = { query = "@parameter.inner", desc = "Swap arg →" },
            ["<leader>sf"] = { query = "@function.outer",  desc = "Swap fn →"  },
          },
          swap_previous = {
            ["<leader>sA"] = { query = "@parameter.inner", desc = "Swap arg ←" },
            ["<leader>sF"] = { query = "@function.outer",  desc = "Swap fn ←"  },
          },
        },

        lsp_interop = {
          enable       = true,
          border       = "single",
          peek_definition_code = {
            ["<leader>pf"] = "@function.outer",
            ["<leader>pc"] = "@class.outer",
          },
        },
      })

      local ts_repeat = require("nvim-treesitter-textobjects.repeatable_move")
      vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat.repeat_last_move_next)
      vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat.repeat_last_move_previous)
      vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat.builtin_f_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat.builtin_F_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat.builtin_t_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat.builtin_T_expr, { expr = true })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    opts  = {
      enable            = true,
      max_lines         = 4,
      min_window_height = 20,
      line_numbers      = true,
      multiline_threshold = 1,
      trim_scope        = "outer",
      mode              = "cursor",
      separator         = "─",
      zindex            = 20,
      on_attach         = function(buf)
        return vim.api.nvim_buf_line_count(buf) > 50
      end,
    },
    config = function(_, opts)
      require("treesitter-context").setup(opts)
      vim.keymap.set("n", "[C", function()
        require("treesitter-context").go_to_context(vim.v.count1)
      end, { desc = "Ir al contexto" })
    end,
  },

  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufReadPost",
    config = function()
      vim.opt.foldlevel      = 99
      vim.opt.foldlevelstart = 99
      vim.opt.foldenable     = true
      vim.opt.foldcolumn     = "1"

      require("ufo").setup({
        open_fold_hl_timeout = 150,
        provider_selector = function(_, filetype)
          local ft_map = {
            vim      = "indent",
            python   = "indent",
            gitignore = "indent",
          }
          return ft_map[filetype] or { "treesitter", "indent" }
        end,
        fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
          local newVirtText = {}
          local suffix      = ("  %d líneas"):format(endLnum - lnum)
          local sufWidth    = vim.fn.strdisplaywidth(suffix)
          local targetWidth = width - sufWidth
          local curWidth    = 0
          for _, chunk in ipairs(virtText) do
            local chunkText  = chunk[1]
            local chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if targetWidth > curWidth + chunkWidth then
              table.insert(newVirtText, chunk)
            else
              chunkText = truncate(chunkText, targetWidth - curWidth)
              table.insert(newVirtText, { chunkText, chunk[2] })
              chunkWidth = vim.fn.strdisplaywidth(chunkText)
              if curWidth + chunkWidth < targetWidth then
                suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
              end
              break
            end
            curWidth = curWidth + chunkWidth
          end
          table.insert(newVirtText, { suffix, "Comment" })
          return newVirtText
        end,
      })

      vim.keymap.set("n", "zR", require("ufo").openAllFolds,             { desc = "Abrir todos los folds"  })
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds,            { desc = "Cerrar todos los folds" })
      vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds,     { desc = "Abrir folds nivel"      })
      vim.keymap.set("n", "zm", require("ufo").closeFoldsWith,           { desc = "Cerrar folds nivel"     })
      vim.keymap.set("n", "K", function()
        local winid = require("ufo").peekFoldedLinesUnderCursor()
        if not winid then vim.lsp.buf.hover() end
      end, { desc = "Peek fold / Hover" })
    end,
  },
}
