return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lua",
      "saadparwaiz1/cmp_luasnip",
      "onsails/lspkind.nvim",
      "rafamadriz/friendly-snippets",
      "kdheepak/cmp-latex-symbols",
      "jmbuhr/cmp-pandoc-references",
      "f3fora/cmp-spell",
      
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      -- 1. PRIMERO: Definir grupos de highlight para que coincidan con Catppuccin
      vim.api.nvim_set_hl(0, "CmpPmenu",          { bg = "#1e1e2e" })  -- Fondo del menú
      vim.api.nvim_set_hl(0, "CmpBorder",         { fg = "#45475a" })  -- Color del borde 'single'
      vim.api.nvim_set_hl(0, "CmpSel",            { bg = "#585b70", bold = true }) -- Item seleccionado
      vim.api.nvim_set_hl(0, "CmpDoc",            { bg = "#181825" })  -- Fondo de documentación
      vim.api.nvim_set_hl(0, "CmpDocBorder",      { fg = "#45475a" })  -- Borde de documentación

      -- 2. Configuración principal de cmp
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete({ reason = cmp.ContextReason.Auto }),
          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true, -- CONFIRMA el item actualmente seleccionado
          }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif vim.snippet and vim.snippet.active({ direction = 1 }) then
              vim.snippet.jump(1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            elseif vim.snippet and vim.snippet.active({ direction = -1 }) then
              vim.snippet.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<C-d>"] = cmp.mapping(function()
            if cmp.visible() then
              cmp.select_next_item({ count = 5 })
            end
          end, { "i" }),
          ["<C-u>"] = cmp.mapping(function()
            if cmp.visible() then
              cmp.select_prev_item({ count = 5 })
            end
          end, { "i" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp",    priority_weight = 100, max_item_count = 10 },
          { name = "luasnip",     priority_weight = 90,  max_item_count = 5 },
          { name = "nvim_lua",    priority_weight = 80 },
          { name = "path",        priority_weight = 70 },
          { name = "latex_symbols", priority_weight = 60, option = { strategy = 2 } },
          { name = "pandoc_references", priority_weight = 50 },
          { name = "spell",       priority_weight = 30, keyword_length = 3 },
        }, {
          { name = "buffer",      priority_weight = 20,
            option = {
              get_bufnrs = function()
                return vim.api.nvim_list_bufs()
              end,
              keyword_pattern = [[\%(-\?\d\+\%(\.\d\+\)\?\|\h\w*\%(-\w*\)*\)]],
              keyword_length = 3,
              max_item_count = 5,
            }
          },
        }),
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = 40,
            ellipsis_char = "…",
            before = function(entry, vim_item)
              vim_item.menu = ({
                nvim_lsp = "[LSP]",
                luasnip = "[Snip]",
                nvim_lua = "[API]",
                path = "[Path]",
                buffer = "[Buf]",
                latex_symbols = "[LaTeX]",
                pandoc_references = "[Ref]",
                spell = "[Spell]",
              })[entry.source.name]
              return vim_item
            end,
          }),
        },
        experimental = {
          ghost_text = {
            hl_group = "Comment",
          },
          native_menu = false,
        },
        window = {
          completion = {
            border = "rounded",
            scrollbar = false, -- Más limpio sin barra de scroll
            winhighlight = "Normal:CmpPmenu,FloatBorder:CmpBorder,CursorLine:CmpSel,Search:None",
            max_width = 60,
            max_height = 12,
            col_offset = 0,
            side_padding = 1,
          },
          documentation = {
            border = "rounded",
            scrollbar = false,
            winhighlight = "Normal:CmpDoc,FloatBorder:CmpDocBorder,Search:None",
            max_width = 70,
            max_height = 15,
          },
        },
        performance = {
          debounce = 60,
          throttle = 100,
          fetching_timeout = 200,
          max_view_entries = 30,
        },
        preselect = cmp.PreselectMode.Item, -- SELECCIONA automáticamente el primer item
        completion = {
          completeopt = "menu,menuone,noinsert,noselect",
          autocomplete = {
            cmp.TriggerEvent.TextChanged,
            cmp.TriggerEvent.InsertEnter,
          },
          keyword_length = 1,
        },
        view = {
          entries = { name = "custom", selection_order = "near_cursor" },
        },
      })

      -- Configuración para línea de comandos
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer", keyword_length = 2 },
        },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources(
          { { name = "path" } },
          { { name = "cmdline",
            option = {
              ignore_cmds = { "Man", "!" }
            }
          } }
        ),
      })

      -- Autocomando para desactivar completado en comentarios
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "*" },
        callback = function()
          vim.b.cmp_enabled = true
          local line = vim.api.nvim_get_current_line()
          local col = vim.api.nvim_win_get_cursor(0)[2]
          local before_cursor = line:sub(1, col)
          if before_cursor:match("^%s*#") or before_cursor:match("//") or before_cursor:match("^%s*--") then
            vim.b.cmp_enabled = false
          end
        end,
      })
    end,
  },
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    dependencies = {
      "rafamadriz/friendly-snippets",
      "honza/vim-snippets",
    },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load({
        paths = {
          vim.fn.stdpath("config") .. "/snippets",
          vim.fn.stdpath("data") .. "/lazy/friendly-snippets",
          vim.fn.stdpath("data") .. "/lazy/vim-snippets",
        }
      })
      require("luasnip.loaders.from_lua").load({ paths = vim.fn.stdpath("config") .. "/lua/snippets" })

      vim.keymap.set({ "i", "s" }, "<C-l>", function()
        if require("luasnip").expand_or_jumpable() then
          require("luasnip").expand_or_jump()
        end
      end, { silent = true, desc = "Expandir o saltar en snippet" })

      vim.keymap.set({ "i", "s" }, "<C-h>", function()
        if require("luasnip").jumpable(-1) then
          require("luasnip").jump(-1)
        end
      end, { silent = true, desc = "Saltar atrás en snippet" })

      vim.keymap.set("i", "<C-e>", function()
        if require("luasnip").choice_active() then
          require("luasnip").change_choice(1)
        end
      end, { desc = "Cambiar opción en nodo choice" })
    end,
  },

}
