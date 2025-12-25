return {
  {
    "danymat/neogen",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("neogen").setup({
        enabled = true,
        languages = {
          lua = { template = { annotation_convention = "ldoc" } },
          python = { template = { annotation_convention = "google_docstrings" } },
          javascript = { template = { annotation_convention = "tsdoc" } },
          typescript = { template = { annotation_convention = "tsdoc" } },
          bash = { template = { annotation_convention = "google_docstrings" } },
          html = { template = { annotation_convention = "plain" } },
          css = { template = { annotation_convention = "plain" } },
          scss = { template = { annotation_convention = "plain" } },
        },
        snippet_engine = "luasnip", -- si usas snippets
      })
    end,
  },
}

