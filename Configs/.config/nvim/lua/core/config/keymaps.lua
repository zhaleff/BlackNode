vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save" })
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>", { desc = "Clear search highlight" })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right" })

vim.keymap.set("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Vertical split" })
vim.keymap.set("n", "<leader>sh", "<cmd>split<CR>", { desc = "Horizontal split" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Equal size" })
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close split" })

vim.keymap.set("n", "<leader>bd", "<cmd>bd<CR>", { desc = "Close buffer" })
