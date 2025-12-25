return {
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "pyright",
          "html",
          "cssls",
          "bashls",
          "jsonls",
          "emmet_language_server",
        },
        automatic_installation = true,
      })
    end,
  },
} 
