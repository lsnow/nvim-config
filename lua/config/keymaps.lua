----------------------------------------------------------------
-- nvim global keymaps                                        --
----------------------------------------------------------------

-- default keymap options
local opts = { noremap = true, silent = true }

-- local alias
local keymap = vim.keymap.set

-- remap leader to space
--keymap("", "<Space>", "<Nop>", opts)
keymap("", ",", "<Nop>", opts)
vim.g.mapleader = ","

----------------------------------------------------------------
-- normal mode ("n")                                          --
----------------------------------------------------------------

-- format current buffer
-- keymap("n", "<leader>lf", vim.lsp.buf.format, { desc = "Format buffer", noremap = true, silent = true })

-- split window below
keymap("n", "<leader>-", "<cmd>split<cr>", { desc = "Split window below", noremap = true, silent = true })

-- split window right
keymap("n", "<leader>|", "<cmd>vsplit<cr>", { desc = "Split window right", noremap = true, silent = true })

-- move lines up or down
keymap("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move Down" })
keymap("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move Up" })

----------------------------------------------------------------
-- insert mode ("i")                                          --
----------------------------------------------------------------

-- move lines up or down
keymap("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
keymap("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })

----------------------------------------------------------------
-- visual mode ("v")                                          --
----------------------------------------------------------------

-- move lines up or down
keymap("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move Down" })
keymap("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move Up" })

----------------------------------------------------------------
-- visual block mode ("x")                                    --
----------------------------------------------------------------

----------------------------------------------------------------
-- term mode ("t")                                            --
----------------------------------------------------------------

----------------------------------------------------------------
-- command mode ("c")                                         --
----------------------------------------------------------------

-- diagnostic
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
-- vim.keymap.set('n', '[g', vim.diagnostic.goto_prev, opts)
-- vim.keymap.set('n', ']g', vim.diagnostic.goto_next, opts)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename) -- smart rename
vim.keymap.set("n", "[g", "<cmd>lua vim.diagnostic.jump({count=-1, float=true})<CR>", opts) -- jump to previous diagnostic in buffer
vim.keymap.set("n", "]g", "<cmd>lua vim.diagnostic.jump({count=1, float=true})<CR>", opts) -- jump to next diagnostic in buffer
vim.keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = "󰋼 ", -- 󰌶 
      [vim.diagnostic.severity.HINT] = "󰌵 ", --  
    },
    texthl = {
      [vim.diagnostic.severity.ERROR] = "Error",
      [vim.diagnostic.severity.WARN] = "Warn",
      [vim.diagnostic.severity.HINT] = "Hint",
      [vim.diagnostic.severity.INFO] = "Info",
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.HINT] = "",
      [vim.diagnostic.severity.INFO] = "",
    },
  },
})
