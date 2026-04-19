-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Eliminar atajos redundantes o de poco uso de LazyVim
for _, key in ipairs({ "<leader>E", "<leader>K", "<leader>L", "<leader>S", "<leader>n" }) do
  pcall(vim.keymap.del, "n", key)
end
