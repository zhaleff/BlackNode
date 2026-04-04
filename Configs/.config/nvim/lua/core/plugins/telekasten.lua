return {
  {
    "nvim-telekasten/telekasten.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    cmd = "Telekasten",
    config = function()
      require("telekasten").setup({
        -- Carpeta donde se guardan tus notas
        home                        = vim.fn.expand("~/notes"),

        dailies                     = vim.fn.expand("~/notes/daily"),
        weeklies                    = vim.fn.expand("~/notes/weekly"),
        templates                   = vim.fn.expand("~/notes/templates"),

        extension                   = ".md",

        auto_set_filetype           = true,

        dailies_create_nonexisting  = true,
        weeklies_create_nonexisting = true,

        new_note_filename           = "title",
      })
    end,
  },
}
