return {
  {
    "windwp/nvim-ts-autotag",
    event = { "InsertEnter" },                            -- Carga solo al entrar en modo insert (más ágil que por ft)
    dependencies = { "nvim-treesitter/nvim-treesitter" }, -- Asegura Treesitter
    opts = {
      autotag = {
        enable = true,
        enable_rename = true,
        enable_close = true,
        enable_close_on_slash = true,
      },
      filetypes = {
        "html", "htmldjango", "xml",
        "javascript", "typescript",
        "javascriptreact", "typescriptreact",
        "jsx", "tsx",
        "svelte", "vue", "astro",
        "php", "blade", "twig", "erb", "heex", "eelixir",
        "rescript",
        "markdown",
      },
    },
    config = function(_, opts)
      require("nvim-ts-autotag").setup(opts)
    end,
  },
}
