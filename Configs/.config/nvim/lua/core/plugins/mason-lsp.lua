return {
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = "VeryLazy",
    config = function()
      local registry = require("core.lsp.registry")

      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(registry),
        automatic_installation = false,
      })
    end,
  },
}
