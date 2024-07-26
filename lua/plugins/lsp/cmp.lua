----------------------------------------------------------------
-- nvim-cmp - completion engine                               --
----------------------------------------------------------------


local function limit_ts_types(entry, ctx)
  local kind = entry:get_completion_item().cmp.kind_text --entry:get_kind()
  local types = require("cmp.types")
  local line = ctx.cursor.line
  local col = ctx.cursor.col
  local char_before_cursor = string.sub(ctx.cursor_line, col - 1, col - 1)
  -- local char_after_dot = string.sub(ctx.cursor_line, col, col)
  --vim.notify = require("notify")
  --vim.notify(entry:get_completion_item().label .. entry:get_completion_item().cmp.kind_text)
  -- if char_before_cursor == "." then -- and char_after_dot:match("[a-zA-Z]") then
  if char_before_cursor == "." or char_before_cursor == '>' then
    if kind == "Property" then
      return true
    else
      return false
    end
  elseif string.match(ctx.cursor_line, "^%s+%w+$") then
    if kind == "Function" or kind == "Variable" or
       kind == "Type" or kind == "TypeBuiltin" or
       kind == "_Parent"
      then
      return true
    else
      return false
    end
  end

  return true
end

return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    -- 'hrsh7th/cmp-nvim-lsp-signature-help',
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path", -- filesystem path completions
    "hrsh7th/cmp-calc",
    "ray-x/cmp-treesitter",
  },
  event = { "InsertEnter", "CmdlineEnter" },
  lazy = true,
  config = function()
    local cmp = require("cmp")
    local cmp_select = { behavior = cmp.SelectBehavior.Select }
    cmp.setup({
      enabled = function()
        -- disable completions in comments
        -- local context = require "cmp.config.context"
        -- keep command mode completion enabled when cursor is in a comment
        --if vim.api.nvim_get_mode().mode == "c" then
        --  return true
        --else
        --  return not context.in_treesitter_capture("comment")
        --      and not context.in_syntax_group("Comment")
        --end
        return true
      end,
      snippet = {
        -- required
        expand = function(args)
          vim.snippet.expand(args.body)
        end,
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      mapping = cmp.mapping.preset.insert({
        -- recommended
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = false }), -- true: Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        -- prime
        ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
        -- ['<C-y>'] = cmp.mapping.confirm({ select = true }),
      }),
      sources = cmp.config.sources({
        {
          name = 'treesitter',
          max_item_count = 20,
          trigger_characters={'.'},
          priority = 49,
          -- Limits treesitter results to specific types based on line context (Fields, Methods, Variables)
          entry_filter = limit_ts_types,
        },
        {
          name = "nvim_lsp",
          max_item_count = 15,
          priority = 51,
          entry_filter = function(entry, _)
            -- using cmp-buffer for this
            -- return require("cmp.types").lsp.CompletionItemKind[entry:get_kind()] ~= "Text"
            return entry:get_kind() ~= require("cmp.types").lsp.CompletionItemKind.Text
          end,
        },
        -- { name = 'nvim_lsp_signature_help', priority = 50 },
        {
          name = "buffer",
          max_item_count = 10,
          priority = 30,
          option = {
            -- show completions from all buffers used within the last x minutes
            get_bufnrs = function()
              local mins = 15 -- CONFIG
              local recentBufs = vim.iter(vim.fn.getbufinfo({ buflisted = 1 }))
              :filter(function(buf)
                return os.time() - buf.lastused < mins * 60
              end)
              :map(function(buf)
                return buf.bufnr
              end)
              :totable()
              return recentBufs
            end,
            max_indexed_line_length = 100, -- no long lines (e.g. base64-encoded things)
          },
        },
        { name = "path", max_item_count = 10, priority = 40 },
        { name = "calc", priority = 10 },
      }),
      matching = {
        disallow_fuzzy_matching = true,
        disallow_fullfuzzy_matching = true,
        disallow_partial_fuzzy_matching = true,
        disallow_partial_matching = true,
        disallow_prefix_unmatching = true,
      },
      sorting = {
        priority_weight = 2,
        comparators = {
          cmp.config.compare.exact,
          cmp.config.compare.locality,
          cmp.config.compare.score,
          cmp.config.compare.recently_used,
          cmp.config.compare.offset,
          cmp.config.compare.sort_text,
          cmp.config.compare.order,
        },
      },
      formatting = {
        format = function(entry, vim_item)
          if entry.source.name ~= "nvim_lsp" then
            vim_item.abbr = string.sub(vim_item.abbr, 1, 50)
          else
            -- Remove the leading character of lsp
            vim_item.abbr = string.sub(vim_item.abbr, 2, 51)
          end
          vim_item.menu = ({
            buffer = "B",
            nvim_lsp = "L",
            luasnip = "S",
            dictionary = "D",
            obsidian = "N",
            path = "P",
            treesitter = "T",
          })[entry.source.name]
          return vim_item
        end,
        expandable_indicator = false,
        fields = { 'abbr', 'kind', 'menu' }
      },
      performance = {
        max_view_entries = 50,
        debounce = 50,
        throttle = 1,
        fetching_timeout = 10,
        confirm_resolve_timeout = 0,
        async_budget = 10,
      }
    })

    cmp.setup.filetype({ 'TelescopePrompt' }, {
        sources = {},
    })

    --cmp.setup.cmdline("/", {
    --    sources = {
    --        { name = "buffer" },
    --    },
    --})
  end,
}
