return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/cmp-nvim-lua",
    "saadparwaiz1/cmp_luasnip",
    "onsails/lspkind.nvim",
    "xzbdmw/colorful-menu.nvim",
    "lukas-reineke/cmp-under-comparator",
    "roobert/tailwindcss-colorizer-cmp.nvim",
  },
  event = { "InsertEnter", "CmdlineEnter" },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local lspkind = require("lspkind")
    local colorful = require("colorful-menu")
    local under = require("cmp-under-comparator")
    local tw_colorizer = require("tailwindcss-colorizer-cmp")

    vim.api.nvim_set_hl(0, "CmpBorder", { fg = "#2a2a2a" })
    vim.api.nvim_set_hl(0, "CmpDocBorder", { fg = "#2a2a2a" })
    vim.api.nvim_set_hl(0, "CmpSel", { bg = "#3a3a3a", bold = true })

    local KIND_ICON = {
      Function = "󰊕",
      Method = "󰆧",
      Variable = "󰀫",
      Class = "󰠱",
      Interface = "",
      Module = "",
      Field = "󰇽",
      Keyword = "󰌋",
      Snippet = "",
    }

    local SOURCE_LABEL = {
      nvim_lsp = "LSP",
      luasnip = "Snip",
      nvim_lua = "API",
      path = "Path",
      buffer = "Buf",
    }

    cmp.setup({
      enabled = function()
        if vim.api.nvim_get_mode().mode == "c" then
          return true
        end
        local buftype = vim.api.nvim_get_option_value("buftype", { buf = 0 })
        if buftype == "prompt" or buftype == "nofile" then
          return false
        end
        local ctx = require("cmp.config.context")
        return not ctx.in_treesitter_capture("comment") and not ctx.in_syntax_group("Comment")
      end,

      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },

      mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),

        ["<CR>"] = cmp.mapping(function(fallback)
          if cmp.visible() and cmp.get_active_entry() then
            cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),

      sources = cmp.config.sources({
        { name = "nvim_lsp", priority_weight = 100, max_item_count = 12 },
        { name = "luasnip", priority_weight = 90, max_item_count = 5 },
        { name = "nvim_lua", priority_weight = 80 },
        { name = "path", priority_weight = 70 },
      }, {
        {
          name = "buffer",
          priority_weight = 20,
          keyword_length = 3,
          max_item_count = 5,
          option = {
            get_bufnrs = function()
              return vim.tbl_filter(function(b)
                return vim.api.nvim_buf_is_loaded(b) and vim.api.nvim_buf_get_name(b) ~= ""
              end, vim.api.nvim_list_bufs())
            end,
          },
        },
      }),

      formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
          local item = entry:get_completion_item()
          local hl_info = colorful.cmp_highlights(item)

          if hl_info then
            vim_item.abbr_hl_group = hl_info.highlights
            vim_item.abbr = hl_info.text
          end

          local icon = KIND_ICON[vim_item.kind] or lspkind.symbol_map[vim_item.kind] or "󰈙"
          vim_item.kind = " " .. icon .. " "

          vim_item.menu = SOURCE_LABEL[entry.source.name] or ""
          vim_item.menu_hl_group = "Comment"

          return tw_colorizer.formatter(entry, vim_item)
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

      completion = {
        completeopt = "menu,menuone,noinsert,noselect",
        keyword_length = 1,
      },

      view = {
        entries = { name = "custom", selection_order = "near_cursor" },
        docs = { auto_open = true },
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
}
