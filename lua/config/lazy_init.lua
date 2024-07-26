----------------------------------------------------------------
-- lazy.nvim plugin manager install and setup                 --
----------------------------------------------------------------

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" },
    { import = "plugins.lsp" },
  },
  install = {
    colorscheme = { "material" },
  },
  ui = {
    size = { width = 0.9, height = 0.9 },
    border = 'rounded',
    backdrop = 100,
    title = ' Plugins (lazy.nvim) ',
  },
  -- check for updates
  checker = {
    enabled = false,
    notify = false,
  },
  rocks = {
    enabled = false,
  },
})

vim.keymap.set("n", "<leader>P", "<cmd>Lazy home<cr>", { desc = "Plugins (Lazy)" })
