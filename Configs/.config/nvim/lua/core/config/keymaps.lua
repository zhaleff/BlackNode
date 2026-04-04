local function setup_keymaps()
  local wk = require("which-key")
  wk.add({
    { "<leader>e",  "<cmd>Neotree toggle<CR>",                  desc = "Explorer (Neo-tree)" },
    { "<leader>t",  "<cmd>ToggleTerm<CR>",                      desc = "Toggle terminal" },
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
    { "<leader>w",  "<cmd>w<CR>",                               desc = "Save file" },
    { "<leader>q",  "<cmd>q<CR>",                               desc = "Quit" },
    { "<leader>b",  group = "Buffer" },
    { "<leader>bd", "<cmd>bd<CR>",                              desc = "Delete buffer" },
    { "<leader>bn", "<cmd>BufferLineCycleNext<CR>",             desc = "Next buffer" },
    { "<leader>bp", "<cmd>BufferLineCyclePrev<CR>",             desc = "Prev buffer" },
    { "<leader>s",  group = "Split / Window" },
    { "<leader>sv", "<cmd>vsplit<CR>",                          desc = "Vertical split" },
    { "<leader>sh", "<cmd>split<CR>",                           desc = "Horizontal split" },
    { "<leader>se", "<C-w>=",                                   desc = "Equal size" },
    { "<leader>sx", "<cmd>close<CR>",                           desc = "Close split" },
    { "<leader>g",  group = "Git" },
    { "<leader>gs", "<cmd>Gitsigns stage_hunk<CR>",             mode = { "n", "v" },         desc = "Stage hunk" },
    { "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>",             mode = { "n", "v" },         desc = "Reset hunk" },
    { "<leader>gp", "<cmd>Gitsigns preview_hunk_inline<CR>",    desc = "Preview hunk" },
    { "<leader>gb", "<cmd>Gitsigns blame_line<CR>",             desc = "Blame line" },
    { "<leader>gd", "<cmd>Gitsigns diffthis<CR>",               desc = "Diff this" },
    { "<leader>x",  group = "Trouble" },
    { "<leader>xd", "<cmd>Trouble diagnostics toggle<CR>",      desc = "Diagnostics" },
    { "<leader>xl", "<cmd>Trouble loclist toggle<CR>",          desc = "Loclist" },
    { "<leader>xq", "<cmd>Trouble quickfix toggle<CR>",         desc = "Quickfix" },
  })

  vim.keymap.set("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
  vim.keymap.set("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Prev buffer" })
  vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>", { desc = "Clear search highlight" })
  vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left" })
  vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down" })
  vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up" })
  vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right" })
  vim.keymap.set("n", "]h", "<cmd>Gitsigns next_hunk<CR>", { desc = "Next hunk" })
  vim.keymap.set("n", "[h", "<cmd>Gitsigns prev_hunk<CR>", { desc = "Prev hunk" })

  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local buf = args.buf
      wk.add({
        { "gd",         vim.lsp.buf.definition,                              desc = "Go to definition",  buffer = buf },
        { "gD",         vim.lsp.buf.declaration,                             desc = "Go to declaration", buffer = buf },
        { "K",          vim.lsp.buf.hover,                                   desc = "Hover",             buffer = buf },
        { "<leader>ca", vim.lsp.buf.code_action,                             desc = "Code action",       buffer = buf },
        { "<leader>rn", vim.lsp.buf.rename,                                  desc = "Rename",            buffer = buf },
        { "gr",         vim.lsp.buf.references,                              desc = "References",        buffer = buf },
        { "gi",         vim.lsp.buf.implementation,                          desc = "Implementation",    buffer = buf },
        { "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, desc = "Format buffer",     buffer = buf },
        { "<C-s>",      vim.lsp.buf.signature_help,                          mode = "i",                 desc = "Signature help", buffer = buf },
      }, { buffer = buf })
    end,
  })
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = setup_keymaps,
  once = true,
})
