----------------------------------------------------------------
-- nvim options                                               --
----------------------------------------------------------------

local options = {
  autoindent = true,                           -- auto indentation
  -- cmdheight = 0,                               -- do not display the cmdline (using telescope cmdline)
  colorcolumn = "80",                          -- highlight the given column
  cursorline = true,                           -- highlight the current line
  expandtab = true,                            -- convert tabs to spaces
  guicursor = "",                              -- disable per-mode cursor styles
  list = false,                                -- show/hide whitespace characters
  listchars = "tab:>-,trail:·,nbsp:·,space:·", -- whitespace characters to show
  number = true,                               -- show line numbers
  relativenumber = false,                      -- make line numbers relative to current line
  scrolloff = 8,                               -- minimal number of screen lines to keep above and below the cursor
  shiftwidth = 2,                              -- size of an indent
  showmode = true,                             -- show '--INSERT--' etc in last line
  sidescrolloff = 8,                           -- minimal number of screen columns either side of cursor if wrap is `false`
  signcolumn = "yes",                          -- always show the sign column, otherwise it would shift the text each time
  smartindent = false,                         -- smart indentation
  cindent = true,                              -- c indentation
  --softtabstop = 2,                             -- how many spaces tabs "feel" like
  --tabstop = 2,                                 -- number of spaces to insert for a tab
  termguicolors = true,                        -- true color support
  wrap = true,                                 -- line wrap
  completeopt = "menu,menuone,noselect",       -- autocompletion
  fileencoding = "utf-8",                      -- The encoding written to file
  backspace = "indent,eol,start",              -- Making sure backspace works
  splitright = true,                           -- Splitting a window will put the new window right of the current one
}

for key, val in pairs(options) do
  vim.opt[key] = val
end

vim.opt.clipboard:append { "unnamedplus" }
