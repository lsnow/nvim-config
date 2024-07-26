-- au BufWritePost * lua require('lint').try_lint()

local severities = {
  ["error"] = vim.diagnostic.severity.ERROR,
  ["warning"] = vim.diagnostic.severity.WARN,
  ["note"] = vim.diagnostic.severity.INFO,
  ["fatal error"] = vim.diagnostic.severity.ERROR,
}

local is_absolute = function(filename)
  return string.sub(filename, 1, 1) == '/'
end

local get_uri_from_path = function(path)
  return 'file://' .. path
end

-- deprecated
local parse_from_text = function(output, bufnr, cwd)
  local result = {}
  local pattern = [[^([^:]+):(%d+):(%d+):%s+([^:]+):%s+(.*)$]]
  for line in output:gmatch("[^\n]+") do
    local file, lnum, col, end_col, message
    local severity
    file, lnum, col, severity, message = line:match(pattern)
    end_col = col
    if message == nil then
      file, lnum = line:match([[^%s+from%s+([^:]+):([^:]+)[:,]+$]])
      col = 0
      end_col = 0
      message = line
      severity = severities["error"]
    end
    if file then
      file = 'build/' .. file
      local tmp_bufnr = bufnr
      local diagnostic = {
        bufnr = tmp_bufnr,
        file = file,
        lnum = tonumber(lnum) - 1,
        col = tonumber(col),
        end_col = tonumber(end_col) + 1,
        message = message,
        severity = severities[severity],
        source = "gcc",
      }
      table.insert(result, diagnostic)
    end
  end
  return result
end

-- https://gcc.gnu.org/onlinedocs/gcc-11.1.0/gcc/Diagnostic-Message-Formatting-Options.html
local parse_diagnostic = function(diag, bufnr, cwd, result)
  local file, lnum, end_lnum, col, end_col, message
  local severity = diag.kind
  local buf_path = vim.api.nvim_buf_get_name(0)
  local tmp_path

  for i = 1, #diag.locations do
    if i == 1 then
      message = diag.message
      if diag.option then
        message = message .. ' [' .. diag.option .. ']'
      end
    else
      message = diag.locations[i].label or ''
    end

    file = diag.locations[i].caret.file
    if is_absolute(file) then
      tmp_path = file
    else
      tmp_path = vim.loop.fs_realpath(cwd .. "/" .. file)
    end

    if tmp_path == buf_path then
    -- local new_bufnr
    --  new_bufnr = vim.uri_to_bufnr(get_uri_from_path(tmp_path))
    -- else
    --  new_bufnr = bufnr
    -- end

    -- if vim.api.nvim_buf_is_valid(new_bufnr) then
      lnum = diag.locations[i].caret.line
      col = diag.locations[i].caret.column
      if diag.locations[i].finish ~= nil then
        end_lnum = diag.locations[i].finish.line
        end_col = diag.locations[i].finish.column
      else
        end_lnum = lnum
        end_col = col
      end
      local diagnostic = {
        bufnr = bufnr,
        file = file,
        lnum = tonumber(lnum) - 1,
        end_lnum = tonumber(end_lnum) - 1,
        col = tonumber(col) - 1,
        end_col = tonumber(end_col) - 1,
        message = message,
        severity = severities[severity],
        source = "gcc",
      }
      table.insert(result, diagnostic)
    end
  end
end

local parse_from_json = function(output, bufnr, cwd)
  local result = {}
  local json = vim.fn.json_decode(output)
  local dir = cwd
  if vim.b.gcc_build_cmds ~= nil then
    dir = vim.b.gcc_build_cmds.directory
  end
  for _, diag in ipairs(json) do
    parse_diagnostic(diag, bufnr, dir, result)

    if diag.children ~= nil then
      for _, child in ipairs(diag.children) do
        parse_diagnostic(child, bufnr, dir, result)
      end
    end
  end
  return result
end

return {
  "mfussenegger/nvim-lint",
  event = "VeryLazy",
  events = { "BufWritePost"},
  enabled = true,
  config = function()
    local lint = require('lint')
    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      callback = function()
        lint.try_lint()
      end,
    })
    lint.linters_by_ft = {
      c = {'gcc'},
      cpp = {'gcc'},
    }
    lint.linters.gcc = {
      name = 'gcc',
      cmd = 'bash',
      stdin = false, -- or false if it doesn't support content input via stdin. In that case the filename is automatically added to the arguments.
      append_fname = false, -- Automatically append the file name to `args` if `stdin = false` (default: true)
      -- args = {'-Wall', '-std=c99'}, -- list of arguments. Can contain functions with zero arguments that will be evaluated once the linter is used.
      args = {'-c',
        function()
          local buf_path = vim.api.nvim_buf_get_name(0)
          if vim.b.build_command == nil then
            local compile_json_path = vim.fs.find(
            {'compile_commands.json'},
            {upward = true, type = 'file', path = './build/'}
            )
            if compile_json_path[1] ~= nil then
              local json = vim.fn.json_decode(vim.fn.readfile(compile_json_path[1]))
              for _, cmds in ipairs(json) do
                local tmp_path = cmds.directory .. "/" .. cmds.file
                if vim.loop.fs_realpath(tmp_path) == buf_path then
                  vim.b.gcc_build_cmds = cmds
                  break
                end
              end
            else
              vim.b.build_command = "gcc -Wall -std=gnu11 -o test.o " .. buf_path
            end
            if vim.b.gcc_build_cmds ~= nil then
              vim.b.build_command = "cd " .. vim.b.gcc_build_cmds.directory .. " && " .. vim.b.gcc_build_cmds.command .. " --diagnostics-format=json"
            else
              vim.b.build_command = "gcc -Wall -Wextra --diagnostics-format=json -o /tmp/test.o " .. buf_path
            end
          end
          return vim.b.build_command
        end,
      },
      stream = 'both', -- ('stdout' | 'stderr' | 'both') configure the stream to which the linter outputs the linting result.
      ignore_exitcode = true, -- set this to true if the linter exits with a code != 0 and that's considered normal.
      env = {LANG = "en_US.UTF-8", GCC_COLORS=""}, -- custom environment table to use with the external process. Note that this replaces the *entire* environment, it is not additive.
      parser = function(output, bufnr, cwd)
        return parse_from_json(output, bufnr, cwd)
      end,
    }
  end,
}
