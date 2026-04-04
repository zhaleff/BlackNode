return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ha", function() require("harpoon"):list():add() end,                        desc = "Harpoon: agregar archivo" },
      { "<leader>hh", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Harpoon: menú" },
      { "<leader>1",  function() require("harpoon"):list():select(1) end,                    desc = "Harpoon: archivo 1" },
      { "<leader>2",  function() require("harpoon"):list():select(2) end,                    desc = "Harpoon: archivo 2" },
      { "<leader>3",  function() require("harpoon"):list():select(3) end,                    desc = "Harpoon: archivo 3" },
      { "<leader>4",  function() require("harpoon"):list():select(4) end,                    desc = "Harpoon: archivo 4" },
    },
  },
}
