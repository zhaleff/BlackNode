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
      "f3fora/cmp-spell",
      "xzbdmw/colorful-menu.nvim",
    },
    event = { "InsertEnter", "CmdlineEnter" },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local colorful_menu = require("colorful-menu")

      -- Highlights Catppuccin
      vim.api.nvim_set_hl(0, "CmpPmenu", { bg = "#1e1e2e" })
      vim.api.nvim_set_hl(0, "CmpBorder", { fg = "#45475a" })
      vim.api.nvim_set_hl(0, "CmpSel", { bg = "#585b70", bold = true })
      vim.api.nvim_set_hl(0, "CmpDoc", { bg = "#181825" })
      vim.api.nvim_set_hl(0, "CmpDocBorder", { fg = "#45475a" })

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

          ["<Tab>"]     = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<S-Tab>"]   = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<C-j>"]     = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-k>"]     = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-d>"]     = cmp.mapping(function() if cmp.visible() then cmp.select_next_item({ count = 5 }) end end,
            { "i" }),
          ["<C-u>"]     = cmp.mapping(function() if cmp.visible() then cmp.select_prev_item({ count = 5 }) end end,
            { "i" }),
        }),

        sources = cmp.config.sources({
          { name = "nvim_lsp",      priority_weight = 100, max_item_count = 10 },
          { name = "luasnip",       priority_weight = 90,  max_item_count = 5 },
          { name = "nvim_lua",      priority_weight = 80 },
          { name = "path",          priority_weight = 70 },
          { name = "latex_symbols", priority_weight = 60,  option = { strategy = 2 } },
          { name = "spell",         priority_weight = 30,  keyword_length = 3 },
        }, {
          {
            name = "buffer",
            priority_weight = 20,
            option = {
              get_bufnrs = function() return vim.api.nvim_list_bufs() end,
              keyword_length = 3,
              max_item_count = 5,
            },
          },
        }),

        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(entry, vim_item)
            local completion_item = entry:get_completion_item()
            local highlights_info = colorful_menu.cmp_highlights(completion_item)

            if highlights_info ~= nil then
              vim_item.abbr_hl_group = highlights_info.highlights
              vim_item.abbr = highlights_info.text
            end

            local kind_symbol = require("lspkind").symbol_map[vim_item.kind] or ""
            vim_item.kind = " " .. kind_symbol .. " "

            vim_item.menu = ({
              nvim_lsp      = "[LSP]",
              luasnip       = "[Snip]",
              nvim_lua      = "[API]",
              path          = "[Path]",
              buffer        = "[Buf]",
              latex_symbols = "[LaTeX]",
              spell         = "[Spell]",
            })[entry.source.name] or ""

            return vim_item
          end,
        },

        sorting = {
          comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.scopes,
            cmp.config.compare.score,
            function(e1, e2)
              local _, u1 = e1.completion_item.label:find("^_+")
              local _, u2 = e2.completion_item.label:find("^_+")
              if u1 ~= u2 then return u1 == nil end
            end,
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
            border = "rounded",
            winhighlight = "Normal:CmpPmenu,FloatBorder:CmpBorder,CursorLine:CmpSel,Search:None",
            max_width = 60,
            max_height = 12,
            side_padding = 1,
          },
          documentation = {
            border = "rounded",
            winhighlight = "Normal:CmpDoc,FloatBorder:CmpDocBorder,Search:None",
            max_width = 70,
            max_height = 15,
          },
        },

        performance = {
          debounce = 60,
          throttle = 30,
          fetching_timeout = 200,
          max_view_entries = 30,
        },

        preselect = cmp.PreselectMode.Item,
        completion = {
          completeopt = "menu,menuone,noinsert,noselect",
          keyword_length = 1,
        },

        view = {
          entries = { name = "custom", selection_order = "near_cursor" },
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
    build = "make install_jsregexp",
    event = "InsertEnter",
    dependencies = {
      "rafamadriz/friendly-snippets",
      "honza/vim-snippets",
    },
    config = function()
      local ls = require("luasnip")
      ls.config.setup({
        history = true,
        update_events = "TextChanged,TextChangedI",
        region_check_events = "CursorMoved,InsertEnter",
        delete_check_events = "TextChanged,InsertLeave",
        enable_autosnippets = false,
      })
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_snipmate").lazy_load()
      require("luasnip.loaders.from_lua").lazy_load({
        paths = vim.fn.stdpath("config") .. "/lua/snippets",
      })

      vim.keymap.set({ "i", "s" }, "<C-l>", function()
        if ls.expand_or_jumpable() then ls.expand_or_jump() end
      end, { silent = true, desc = "LuaSnip: Expand or Jump" })

      vim.keymap.set({ "i", "s" }, "<C-h>", function()
        if ls.jumpable(-1) then ls.jump(-1) end
      end, { silent = true, desc = "LuaSnip: Jump Back" })

      vim.keymap.set("i", "<C-e>", function()
        if ls.choice_active() then ls.change_choice(1) end
      end, { silent = true, desc = "LuaSnip: Next Choice" })
    end,
  },
}
