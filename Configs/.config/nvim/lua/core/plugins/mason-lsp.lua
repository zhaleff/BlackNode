return {
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    dependencies = {
      "williamboman/mason.nvim",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "pyright",
          "tailwindcss",
          "html",
          "cssls",
          "emmet_ls",
          "ts_ls",
          "bashls",
          "jsonls",
        },
        -- Desactivamos automatic_installation porque estás usando vim.lsp.config
        -- (no hooks en lspconfig.setup), así evitamos comportamientos inesperados.
        -- Con ensure_installed todo se instala al inicio de Neovim y persiste siempre.
        automatic_installation = false,
      })
    end,
  },
}
