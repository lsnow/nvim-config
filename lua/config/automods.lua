----------------------------------------------------------------
-- nvim automods                                              --
----------------------------------------------------------------

local function augroup(name)
  return vim.api.nvim_create_augroup("lsnow_" .. name, { clear = true })
end

-- auto trim trailing whitespace on write

--vim.api.nvim_create_autocmd({ "BufWritePre" }, {
--  pattern = { "*" },
--  callback = function()
--    local save_cursor = vim.fn.getpos(".")
--    pcall(function() vim.cmd [[%s/\s\+$//e]] end)
--    vim.fn.setpos(".", save_cursor)
--  end,
--})

-- auto format via lsp on write
--[[
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  callback = function()
    vim.lsp.buf.format()
  end,
})
--]]

-- return to last edit position when opening buffer
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
  -- group = "bufcheck",
  pattern = "*",
  callback = function()
    if vim.fn.line("'\"") > 0 and vim.fn.line("'\"") <= vim.fn.line("$") then
      vim.fn.setpos('.', vim.fn.getpos("'\""))
      vim.api.nvim_feedkeys('zz', 'n', true)
    end
  end,
})

-- big file settings
vim.api.nvim_create_autocmd({'BufReadPre'}, {
  pattern = "*",
  callback = function(info)
    vim.b.bigfile = false
    local stat = vim.uv.fs_stat(info.match)
    if stat and stat.size > 1048576 then
      vim.b.bigfile = true
      vim.opt_local.spell = false
      vim.opt_local.swapfile = false
      vim.opt_local.undofile = false
      vim.opt_local.breakindent = false
      vim.opt_local.colorcolumn = ''
      vim.opt_local.statuscolumn = ''
      vim.opt_local.signcolumn = 'no'
      vim.opt_local.foldcolumn = '0'
      vim.opt_local.winbar = ''
      vim.cmd.syntax('off')
    end
  end,
})

-- start terminal in insert mode
--vim.api.nvim_create_autocmd('TermOpen', {
--  -- group   = "bufcheck",
--  pattern = "*",
--  command = "startinsert | set winfixheight"
--})

vim.api.nvim_create_autocmd("FileType", {
  pattern = {"c", "cpp"},
  callback = function()
    vim.bo.cinoptions = vim.bo.cinoptions .. "(0"
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})
