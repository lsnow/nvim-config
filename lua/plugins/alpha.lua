----------------------------------------------------------------
-- alpha-nvim - dashboard/greeter                             --
-- goolord/alpha-nvim
----------------------------------------------------------------

return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  --dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local dashboard = require("alpha.themes.dashboard")

    -- nav buttons
    dashboard.section.buttons.val = {
      dashboard.button("SPC f f", "  Find files", "<cmd>Telescope find_files <cr>"),
      dashboard.button("SPC M", "󰉻  Buffer list", "<cmd>Telescope buffers<cr>"),
      dashboard.button("SPC f r", "  Find recent files", "<cmd>Telescope oldfiles <cr>"),
      dashboard.button("SPC .", "󰙅  File explorer", "<cmd>Neotree toggle<cr>"),
      dashboard.button("SPC f t", "󱎸  Find text", "<cmd>Telescope live_grep <cr>"),
      dashboard.button("SPC G", "󱖫  Git client", "<cmd>LazyGit <cr>"),
      -- dashboard.button("SPC f d", "  Find todos", "<cmd>TodoTelescope <cr>"),
      dashboard.button("SPC P", "󰩦  Plugins", "<cmd>Lazy home <cr>"),
      dashboard.button("SPC D", "󰕮  Toggle dashboard", "<cmd>Alpha<cr>"),
      dashboard.button("q", "  Quit Neovim", "<cmd>qa<CR>"),
    }

    -- close Lazy and re-open when the dashboard is ready
    if vim.o.filetype == "lazy" then
      vim.cmd.close()
      vim.api.nvim_create_autocmd("User", {
        once = true,
        pattern = "AlphaReady",
        callback = function()
          require("lazy").show()
        end,
      })
    end

    require("alpha").setup(dashboard.config)

    -- build footer
    vim.api.nvim_create_autocmd("User", {
      callback = function()
        local stats = require("lazy").stats()
        local ms = math.floor(stats.startuptime * 100) / 100
        local stats_line = "󱐌 Loaded "
            .. stats.loaded
            .. "/"
            .. stats.count
            .. " plugins in "
            .. ms
            .. "ms"

        local v = vim.version()
        local version_line = " v" .. v.major .. "." .. v.minor .. "." .. v.patch

        local stats_line_width = vim.fn.strdisplaywidth(stats_line)
        local version_line_padded = string.rep(" ", (stats_line_width - vim.fn.strdisplaywidth(version_line)) / 2) ..
            version_line

        dashboard.section.footer.val = {
          stats_line, "", version_line_padded
        }
        pcall(vim.cmd.AlphaRedraw)
      end,
    })
  end,
}
