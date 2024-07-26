----------------------------------------------------------------
-- rhysd/git-messenger.vim'
----------------------------------------------------------------

return {
  "rhysd/git-messenger.vim",
  enabled = true,
  config = function()
    vim.keymap.set('n', "<leader>gm", "<cmd>GitMessenger<cr>", { desc = "git messenger"})
  end,
}
