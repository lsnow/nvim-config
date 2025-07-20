----------------------------------------------------------------
-- nvim-treesitter - tree-sitter integration                  --
----------------------------------------------------------------

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    -- only load treesitter in buffers
    event = { "BufReadPre", "BufNewFile", },
    dependencies = {
      --"nvim-treesitter/nvim-treesitter-textobjects",
      "nvim-treesitter/nvim-treesitter-context",
      --"nvim-treesitter/nvim-treesitter-refactor",
      "m-demare/hlargs.nvim",
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        highlight = {
          enable = true,
        },
        indent = {
          enable = false
        },
        ensure_installed = {
          -- required
          "lua",
          "query",
          "vim",
          "vimdoc",
          -- custom
          "c",
          "cpp",
          "comment",
          "ini",
          "cuda",
          "glsl",
          -- "html",
          "markdown",
          "markdown_inline",
          "python",
          "rust",
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<cr>",
            node_incremental = "<cr>",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },
      })
      require("hlargs").setup{}
      require'treesitter-context'.setup{
        enable = true,
      }
    end,
  },
}
