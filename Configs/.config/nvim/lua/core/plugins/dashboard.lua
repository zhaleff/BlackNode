return {
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local hyprcraft = [[



_____________________                              _____________________
`-._:  .:'   `:::  .:\           |\__/|           /::  .:'   `:::  .:.-'
    \      :          \          |:   |          /         :       /    
     \     ::    .     `-_______/ ::   \_______-'   .      ::   . /      
      |  :   :: ::'  :   :: ::'  :   :: ::'      :: ::'  :   :: :|       
      |     ;::         ;::         ;::         ;::         ;::  |       
      |  .:'   `:::  .:'   `:::  .:'   `:::  .:'   `:::  .:'   `:|       
      /     :           :           :           :           :    \       
     /______::_____     ::    .     ::    .     ::   _____._::____\      
                   `----._:: ::'  :   :: ::'  _.----'                    
                          `--.       ;::  .--'                           
                              `-. .:'  .-'                               
                                 \    / :F_P:                            
                                  \  /                                   
                                   \/ 
    ]]
      require("dashboard").setup({
        theme = "doom",
        config = {
          header = vim.split(hyprcraft, "\n"),
          center = {
            { icon = " ", desc = "NvimTree        ", key = "e", action = "NvimTreeToggle" },
            { icon = " ", desc = "Find Files      ", key = "f", action = "Telescope find_files" },
            { icon = " ", desc = "Recent Files    ", key = "r", action = "Telescope oldfiles" },
            { icon = " ", desc = "Live Grep       ", key = "g", action = "Telescope live_grep" },
            { icon = "󰚰 ", desc = "Update Plugins  ", key = "u", action = "Lazy update" },
            { icon = "󰩈 ", desc = "Quit            ", key = "q", action = "qa" },
          },
          footer = function()
            local stats = require("lazy").stats()
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
            return { "", "HyprCraft 2025  •  " .. stats.count .. " plugins loaded in " .. ms .. "ms" }
          end,
        },
      })
    end
  }
}
