return {
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(require("core.lsp.registry")),
        automatic_installation = false,
      })
    end,
  },
}
