return {
  {
    "giusgad/pets.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "giusgad/hologram.nvim" },
    config = function()
      require("pets").setup({
        autostart = false, -- No spawnea ningún pet al iniciar
        -- Puedes agregar más opciones si quieres
        -- e.g. default_pet = nil
      })

      -- Opcional: asignar un comando para abrir la selección
      vim.api.nvim_create_user_command("SpawnPet", function()
        require("pets").spawn()
      end, {})
    end,
  }
}
