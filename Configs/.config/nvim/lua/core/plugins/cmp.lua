return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lua",
      "saadparwaiz1/cmp_luasnip",
      "onsails/lspkind.nvim",
      "kdheepak/cmp-latex-symbols",
      "f3fora/cmp-spell",
      "xzbdmw/colorful-menu.nvim",
      "lukas-reineke/cmp-under-comparator",
      "roobert/tailwindcss-colorizer-cmp.nvim",
      "Exafunction/codeium.nvim",
    },
    event = { "InsertEnter", "CmdlineEnter" },
    config = function()
      local cmp          = require("cmp")
      local luasnip      = require("luasnip")
      local lspkind      = require("lspkind")
      local colorful     = require("colorful-menu")
      local under        = require("cmp-under-comparator")
      local tw_colorizer = require("tailwindcss-colorizer-cmp")

      vim.api.nvim_set_hl(0, "CmpBorder", { fg = "#45475a" })
      vim.api.nvim_set_hl(0, "CmpSel", { bg = "#585b70", bold = true })
      cmp.setup({
        enabled = function()
          if vim.api.nvim_get_mode().mode == "c" then return true end
          if vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "prompt" then return false end
          if vim.fn.reg_recording() ~= "" or vim.fn.reg_executing() ~= "" then return false end
          local ctx = require("cmp.config.context")
          return not ctx.in_treesitter_capture("comment") and not ctx.in_syntax_group("Comment")
        end,

        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },

        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"]      = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),

          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),

          ["<C-d>"] = cmp.mapping(function()
            if cmp.visible() then cmp.select_next_item({ count = 5 }) end
          end, { "i" }),

          ["<C-u>"] = cmp.mapping(function()
            if cmp.visible() then cmp.select_prev_item({ count = 5 }) end
          end, { "i" }),
        }),

        sources = cmp.config.sources({
          { name = "codeium",          priority_weight = 110, max_item_count = 3  },
          { name = "nvim_lsp",         priority_weight = 100, max_item_count = 10 },
          { name = "nvim_lsp_signature_help", priority_weight = 95 },
          { name = "luasnip",          priority_weight = 90,  max_item_count = 5  },
          { name = "nvim_lua",         priority_weight = 80 },
          { name = "path",             priority_weight = 70 },
          { name = "latex_symbols",    priority_weight = 60, option = { strategy = 2 } },
          { name = "spell",            priority_weight = 30, keyword_length = 3 },
        }, {
          {
            name = "buffer",
            priority_weight = 20,
            keyword_length = 3,
            max_item_count = 5,
            option = {
              get_bufnrs = function()
                return vim.tbl_filter(function(b)
                  return vim.api.nvim_buf_is_loaded(b)
                    and vim.api.nvim_buf_get_name(b) ~= ""
                end, vim.api.nvim_list_bufs())
              end,
            },
          },
        }),

        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(entry, vim_item)
            local item      = entry:get_completion_item()
            local hl_info   = colorful.cmp_highlights(item)

            if hl_info then
              vim_item.abbr_hl_group = hl_info.highlights
              vim_item.abbr          = hl_info.text
            end

            local kind_icon  = lspkind.symbol_map[vim_item.kind] or ""
            local kind_color = ({
              Class     = "CmpItemKindClass",
              Function  = "CmpItemKindFunction",
              Method    = "CmpItemKindMethod",
              Variable  = "CmpItemKindVariable",
              Keyword   = "CmpItemKindKeyword",
              Snippet   = "CmpItemKindSnippet",
              Field     = "CmpItemKindField",
              Module    = "CmpItemKindModule",
              Interface = "CmpItemKindInterface",
            })[vim_item.kind]

            vim_item.kind      = " " .. kind_icon .. " "
            vim_item.kind_hl_group = kind_color

            vim_item.menu = ({
              codeium   = "󰚩 AI",
              nvim_lsp  = "󰒋 LSP",
              luasnip   = " Snip",
              nvim_lua  = " API",
              path      = " Path",
              buffer    = "󰈙 Buf",
              latex_symbols = " LaTeX",
              spell     = "󰓆 Spell",
              nvim_lsp_signature_help = "󰊕 Sig",
            })[entry.source.name] or ""

            vim_item.menu_hl_group = "Comment"

            vim_item = tw_colorizer.formatter(entry, vim_item)

            return vim_item
          end,
        },

        sorting = {
          priority_weight = 2,
          comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            under.under,
            cmp.config.compare.recently_used,
            cmp.config.compare.locality,
            cmp.config.compare.kind,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },

        experimental = {
          ghost_text = { hl_group = "Comment" },
        },

        window = {
          completion = {
            border        = "rounded",
            winhighlight  = "Normal:CmpPmenu,FloatBorder:CmpBorder,CursorLine:CmpSel,Search:None",
            max_width     = 60,
            max_height    = 12,
            side_padding  = 1,
            col_offset    = -3,
          },
          documentation = {
            border       = "rounded",
            winhighlight = "Normal:CmpDoc,FloatBorder:CmpDocBorder,Search:None",
            max_width    = 70,
            max_height   = 15,
          },
        },

        performance = {
          debounce         = 60,
          throttle         = 30,
          fetching_timeout = 200,
          max_view_entries = 30,
        },

        preselect = cmp.PreselectMode.Item,
        completion = {
          completeopt  = "menu,menuone,noinsert,noselect",
          keyword_length = 1,
        },

        view = {
          entries = { name = "custom", selection_order = "near_cursor" },
          docs    = { auto_open = true },
        },
      })

      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer", keyword_length = 2 } },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources(
          { { name = "path" } },
          { { name = "cmdline", option = { ignore_cmds = { "Man", "!" } } } }
        ),
      })
    end,
  },

  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build   = "make install_jsregexp",
    event   = "InsertEnter",
    dependencies = {
      "rafamadriz/friendly-snippets",
      "honza/vim-snippets",
    },
    config = function()
      local ls = require("luasnip")

      ls.config.setup({
        history               = true,
        update_events         = "TextChanged,TextChangedI",
        region_check_events   = "CursorMoved,InsertEnter",
        delete_check_events   = "TextChanged,InsertLeave",
        enable_autosnippets   = false,
        ext_opts = {
          [require("luasnip.util.types").choiceNode] = {
            active = { virt_text = { { "●", "DiagnosticWarn" } } },
          },
        },
      })

      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_snipmate").lazy_load()
      require("luasnip.loaders.from_lua").lazy_load({
        paths = vim.fn.stdpath("config") .. "/lua/snippets",
      })

      vim.keymap.set({ "i", "s" }, "<C-l>", function()
        if ls.expand_or_jumpable() then ls.expand_or_jump() end
      end, { silent = true })

      vim.keymap.set({ "i", "s" }, "<C-h>", function()
        if ls.jumpable(-1) then ls.jump(-1) end
      end, { silent = true })

      vim.keymap.set("i", "<C-e>", function()
        if ls.choice_active() then ls.change_choice(1) end
      end, { silent = true })
    end,
  },

  {
    "Exafunction/codeium.nvim",
    cmd   = "Codeium",
    event = "InsertEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      require("codeium").setup({
        enable_chat = false,
      })
    end,
  },

  {
    "roobert/tailwindcss-colorizer-cmp.nvim",
    opts = { color_square_width = 2 },
  },
}
