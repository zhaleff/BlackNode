-- Define la función de configuración, pero NO la ejecutes todavía
local function setup_keymaps()
  -- Mover el require DENTRO de esta función
  local wk = require("which-key")
  
  wk.add({
    { "<leader>e",  ":NvimTreeToggle<CR>",             desc = "Explorer" },
    { "<leader>f",  group = "Find" },
    { "<leader>ff", ":Telescope find_files<CR>",       desc = "Files" },
    { "<leader>fg", ":Telescope live_grep<CR>",        desc = "Grep" },
    { "<leader>fb", ":Telescope buffers<CR>",          desc = "Buffers" },
    { "<leader>fo", ":Telescope oldfiles<CR>",         desc = "Old Files" },
    { "<leader>fh", ":Telescope help_tags<CR>",        desc = "Help" },
    { "<leader>w",  ":w<CR>",                          desc = "Save" },
    { "<leader>q",  ":q<CR>",                          desc = "Quit" },
    { "<leader>b",  group = "Buffer" },
    { "<leader>bd", ":bd<CR>",                         desc = "Delete" },
    { "<leader>x",  group = "Trouble" },
    { "<leader>xd", ":Trouble diagnostics toggle<CR>", desc = "Diagnostics" },
    { "<leader>xl", ":Trouble loclist toggle<CR>",     desc = "Loclist" },
    { "<leader>xq", ":Trouble quickfix toggle<CR>",    desc = "Quickfix" },
  })

  vim.keymap.set("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next Buffer" })
  vim.keymap.set("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Prev Buffer" })
  vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>", { desc = "Clear Search" })

  -- LSP KEYMAPS (UN solo autocmd, elimina el duplicado)
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local buf = args.buf
      wk.add({
        { "gd",         vim.lsp.buf.definition,     desc = "Go to Definition", buffer = buf },
        { "K",          vim.lsp.buf.hover,          desc = "Hover",            buffer = buf },
        { "<leader>ca", vim.lsp.buf.code_action,    desc = "Code Action",      buffer = buf },
        { "<leader>rn", vim.lsp.buf.rename,         desc = "Rename",           buffer = buf },
        { "gr",         vim.lsp.buf.references,     desc = "References",       buffer = buf },
        { "gi",         vim.lsp.buf.implementation, desc = "Implementation",   buffer = buf },
      }, { buffer = buf })
    end,
  })
end

-- Programa la ejecución para después de que Vim y los plugins estén completamente cargados
vim.api.nvim_create_autocmd("VimEnter", {
  callback = setup_keymaps,
  once = true, -- Solo ejecutar una vez
})

-- Generar doc de función o método
vim.keymap.set("n", "<leader>gd", function()
  require("neogen").generate({ type = "func" })
end, { desc = "Generar doc de función" })

-- Generar doc de clase
vim.keymap.set("n", "<leader>gc", function()
  require("neogen").generate({ type = "class" })
end, { desc = "Generar doc de clase" })

