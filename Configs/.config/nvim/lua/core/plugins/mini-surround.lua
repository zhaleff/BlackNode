return {
  {
    "echasnovski/mini.surround",
    version = "*",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      mappings = {
        add            = "gsa",
        delete         = "gsd",
        replace        = "gsr",
        find           = "gsf",
        find_left      = "gsF",
        highlight      = "gsh",
        update_n_lines = "gsn",
      },
      n_lines = 20,
      custom_surroundings = {
        t = {
          input = { "<(%w-)%f[^%w][^>]->(.-)</%1>", "^<.->().-()</[^/]->$" },
          output = function()
            local tag = vim.fn.input("Tag: ")
            return { left = "<" .. tag .. ">", right = "</" .. tag .. ">" }
          end,
        },
      },
    },
  },
}
