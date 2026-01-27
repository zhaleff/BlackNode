-- Define la función de configuración, pero NO la ejecutes todavía
local function setup_keymaps()
  -- Mover el require DENTRO de esta función (buena práctica para lazy loading)
  local wk = require("which-key")

  wk.add({
    { "<leader>e",  "<cmd>Neotree toggle<CR>",                  desc = "Explorer (Neo-tree)" },

    { "<leader>f",  group = "Find" },
    { "<leader>ff", "<cmd>Telescope find_files<CR>",            desc = "Files" },
    { "<leader>fg", "<cmd>Telescope live_grep<CR>",             desc = "Grep" },
    { "<leader>fw", "<cmd>Telescope grep_string<CR>",           desc = "Word under cursor" },
    { "<leader>fb", "<cmd>Telescope buffers<CR>",               desc = "Buffers" },
    { "<leader>fo", "<cmd>Telescope oldfiles<CR>",              desc = "Recent Files" },
    { "<leader>fh", "<cmd>Telescope help_tags<CR>",             desc = "Help" },
    { "<leader>fk", "<cmd>Telescope keymaps<CR>",               desc = "Keymaps" },
    { "<leader>fc", "<cmd>Telescope commands<CR>",              desc = "Commands" },
    { "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>",  desc = "Symbols (buffer)" },
    { "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<CR>", desc = "Symbols (workspace)" },
    { "<leader>fr", "<cmd>Telescope resume<CR>",                desc = "Resume last search" },
    { "<leader>ft", "<cmd>TodoTelescope<CR>",                   desc = "TODOs/FIXMEs" },

    { "<leader>v",  group = "Viewport / Motion" },
    { "<leader>vf", "gg",                                       desc = "First Line" },
    { "<leader>vl", "G",                                        desc = "Last Line" },
    { "<leader>vc", "zz",                                       desc = "Center Cursor" },
    { "<leader>vt", "zt",                                       desc = "Cursor to Top" },
    { "<leader>vb", "zb",                                       desc = "Cursor to Bottom" },

    { "<leader>w",  "<cmd>w<CR>",                               desc = "Save" },
    { "<leader>q",  "<cmd>q<CR>",                               desc = "Quit" },
    { "<leader>b",  group = "Buffer" },
    { "<leader>bd", "<cmd>bd<CR>",                              desc = "Delete" },
    { "<leader>bn", "<cmd>BufferLineCycleNext<CR>",             desc = "Next" },
    { "<leader>bp", "<cmd>BufferLineCyclePrev<CR>",             desc = "Prev" },

    { "<leader>s",  group = "Split / Window" },
    { "<leader>sv", "<cmd>vsplit<CR>",                          desc = "Vertical Split" },
    { "<leader>sh", "<cmd>split<CR>",                           desc = "Horizontal Split" },
    { "<leader>se", "<C-w>=",                                   desc = "Equal Size" },
    { "<leader>sx", "<cmd>close<CR>",                           desc = "Close Split" },

    { "<leader>g",  group = "Git" },
    { "<leader>gs", "<cmd>Gitsigns stage_hunk<CR>",             mode = { "n", "v" },         desc = "Stage Hunk" },
    { "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>",             mode = { "n", "v" },         desc = "Reset Hunk" },
    { "<leader>gp", "<cmd>Gitsigns preview_hunk_inline<CR>",    desc = "Preview Hunk" },
    { "<leader>gb", "<cmd>Gitsigns blame_line<CR>",             desc = "Blame Line" },
    { "<leader>gd", "<cmd>Gitsigns diffthis<CR>",               desc = "Diff This" },

    { "<leader>x",  group = "Trouble" },
    { "<leader>xd", "<cmd>Trouble diagnostics toggle<CR>",      desc = "Diagnostics" },
    { "<leader>xl", "<cmd>Trouble loclist toggle<CR>",          desc = "Loclist" },
    { "<leader>xq", "<cmd>Trouble quickfix toggle<CR>",         desc = "Quickfix" },
  })

  -- Buffer navigation (con desc para que aparezcan en which-key)
  vim.keymap.set("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next Buffer" })
  vim.keymap.set("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Prev Buffer" })

  -- Limpieza
  vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>", { desc = "Clear Search Highlight" })

  -- Navegación entre ventanas (Ctrl+hjkl – imprescindible, no necesita leader)
  vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window Left" })
  vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window Down" })
  vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window Up" })
  vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window Right" })

  -- Git hunk navigation (bare keys)
  vim.keymap.set("n", "]h", "<cmd>Gitsigns next_hunk<CR>", { desc = "Next Hunk" })
  vim.keymap.set("n", "[h", "<cmd>Gitsigns prev_hunk<CR>", { desc = "Prev Hunk" })

  -- LSP KEYMAPS (un solo autocmd, buffer-specific)
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local buf = args.buf
      wk.add({
        { "gd",         vim.lsp.buf.definition,                              desc = "Go to Definition",  buffer = buf },
        { "gD",         vim.lsp.buf.declaration,                             desc = "Go to Declaration", buffer = buf },
        { "K",          vim.lsp.buf.hover,                                   desc = "Hover",             buffer = buf },
        { "<leader>ca", vim.lsp.buf.code_action,                             desc = "Code Action",       buffer = buf },
        { "<leader>rn", vim.lsp.buf.rename,                                  desc = "Rename",            buffer = buf },
        { "gr",         vim.lsp.buf.references,                              desc = "References",        buffer = buf },
        { "gi",         vim.lsp.buf.implementation,                          desc = "Implementation",    buffer = buf },
        { "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, desc = "Format Buffer",     buffer = buf },
        { "<C-s>",      vim.lsp.buf.signature_help,                          mode = "i",                 desc = "Signature Help", buffer = buf },
      }, { buffer = buf })
    end,
  })
end

-- Ejecutar después de que Vim y plugins estén completamente cargados
vim.api.nvim_create_autocmd("VimEnter", {
  callback = setup_keymaps,
  once = true,
})
