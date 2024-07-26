-- lsp servers
-- disable lsp highlighting
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      client.server_capabilities.semanticTokensProvider = nil
    end
  end,
});

return {
  {
    "neovim/nvim-lspconfig",
    enabled = true,
    event = { "BufReadPost", "BufNewFile" },
    lazy = true,
    cmd = { "LspInfo", "LspInstall", "LspUninstall", "LspStart" },
    config = function()
      local lspconfig = require("lspconfig")

      local M = {}

      M.on_attach = function(client, _)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end

      M.capabilities = vim.lsp.protocol.make_client_capabilities()

      M.capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true
      }

      M.capabilities.textDocument.completion.completionItem = {
        documentationFormat = { "markdown", "plaintext" },
        snippetSupport = true,
        preselectSupport = true,
        insertReplaceSupport = true,
        labelDetailsSupport = true,
        deprecatedSupport = true,
        commitCharactersSupport = true,
        tagSupport = { valueSet = { 1 } },
        resolveSupport = {
          properties = {
            "documentation",
            "detail",
            "additionalTextEdits",
          },
        },
      }

      -- local servers = { "html", "pyright", "tsserver", "emmet_ls", "clangd", "cssls", "rnix", "hls", "gopls", "astro", "vuels" }
      local servers = {}

      for _, k in ipairs(servers) do
        lspconfig[k].setup {
          on_attach = M.on_attach,
          capabilities = M.capabilities,
        }
      end

      -- disable diagnostics of clangd.
      lspconfig.clangd.setup({
        capabilities = M.capabilities,
        handlers = {
          ["textDocument/publishDiagnostics"] = function() end,
        },
      })

      lspconfig.rust_analyzer.setup {
        filetypes = { "rust" },
        cmd = { "rustup", "run", "stable", "rust-analyzer" },
      }

      lspconfig.lua_ls.setup {
        on_attach = M.on_attach,
        capabilities = M.capabilities,

        settings = {
          Lua = {
            completion = {
              callSnippet = "Replace"
            },
            diagnostics = {
              globals = { "vim", "awesome", "client", "screen", "mouse", "tag" },
            },
          },
        }
      }
    end,
  },
}
