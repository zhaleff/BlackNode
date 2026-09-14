return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local autopairs = require("nvim-autopairs")

      autopairs.setup({
        check_ts = true,
        ts_config = {
          lua = { "string" },
          javascript = { "template_string" },
          typescript = { "template_string" },
        },
        fast_wrap = {
          map = "<M-e>",
          chars = { "{", "[", "(", '"', "'" },
          pattern = [=[[%'%"%)%>%]%)%}%,]]=],
          end_key = "$",
          keys = "qwertyuiopzxcvbnmasdfghjkl",
          check_comma = true,
          highlight = "Search",
          highlight_grey = "Comment",
        },
      })

      local ok, cmp = pcall(require, "cmp")
      if ok then
        cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
      end
    end,
  },
}
