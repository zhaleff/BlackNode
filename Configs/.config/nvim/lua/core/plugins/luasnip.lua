return {
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    event = "InsertEnter",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      local ls = require("luasnip")

      ls.config.setup({
        history = true,
        update_events = "TextChanged,TextChangedI",
        region_check_events = "CursorMoved,InsertEnter",
        delete_check_events = "TextChanged,InsertLeave",
        enable_autosnippets = true,
        ext_opts = {
          [require("luasnip.util.types").choiceNode] = {
            active = { virt_text = { { "●", "DiagnosticWarn" } } },
          },
        },
      })

      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_lua").lazy_load({
        paths = vim.fn.stdpath("config") .. "/lua/snippets",
      })

      vim.keymap.set({ "i", "s" }, "<C-l>", function()
        if ls.expand_or_jumpable() then
          ls.expand_or_jump()
        end
      end, { silent = true })

      vim.keymap.set({ "i", "s" }, "<C-h>", function()
        if ls.jumpable(-1) then
          ls.jump(-1)
        end
      end, { silent = true })

      vim.keymap.set("i", "<C-e>", function()
        if ls.choice_active() then
          ls.change_choice(1)
        end
      end, { silent = true })
    end,
  },
}
