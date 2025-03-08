----------------------------------------------------------------
-- alpha-nvim - dashboard/greeter                             --
-- goolord/alpha-nvim
----------------------------------------------------------------

local get_current_function = function()
  local node = vim.treesitter.get_node()
  while node do
    if node:type() == "function_definition" or
      node:type() == "function_declaration" or
      node:type() == "function_item" then
      return vim.treesitter.get_node_text(node, 0)
      -- local cur_row = vim.api.nvim_win_get_cursor(0)[1]
      -- local start_row = node:range()
      -- local lines = vim.api.nvim_buf_get_lines(0, start_row, cur_row, false)
      -- return table.concat(lines, '\n')
    end
    node = node:parent()
  end
  return nil
end

return {
  "frankroeder/parrot.nvim",
  event = "VimEnter",
  -- dependencies = { 'ibhagwan/fzf-lua', 'nvim-lua/plenary.nvim' },
  dependencies = { 'nvim-lua/plenary.nvim' },
  -- optionally include "folke/noice.nvim" or "rcarriga/nvim-notify" for beautiful notifications
  config = function(_, opts)
    -- add ollama if executable found
    if vim.fn.executable "ollama" == 1 then
      opts.providers["ollama"] = {}
    end
    require("parrot").setup(opts)
  end,
  opts = {
    -- Providers must be explicitly added to make them available.
    providers = {
      custom = {
        style = "openai",
        api_key = os.getenv "DEEPSEEK_API_KEY",
        endpoint = "https://api.deepseek.com/v1/chat/completions",
        models = {
          "deepseek-chat",
          "deepseek-reasoner",
        },
        -- parameters to summarize chat
        topic = {
          model = "deepseek-chat",
          params = { max_completion_tokens = 1024 },
        },
        -- default parameters
        params = {
          chat = { temperature = 1.1, top_p = 1 },
          command = { temperature = 1.1, top_p = 1 },
        },
      },
      openrouter = {
        style = "openai",
        api_key = os.getenv "OPENROUTER_API_KEY",
        endpoint = "https://openrouter.ai/api/v1/chat/completions",
        models = {
          "qwen/qwq-32b:free",
          "deepseek/deepseek-r1-zero:free",
          "deepseek/deepseek-r1",
          "google/gemini-2.0-flash-001", -- $0.1/0.4 0.5s
          "anthropic/claude-3.7-sonnet:beta", -- $3/15
          "anthropic/claude-3.7-sonnet", -- $3/15
          "anthropic/claude-3.7-sonnet:thinking", -- $3/15
          "anthropic/claude-3.5-sonnet", -- $3/15
          "openai/o3-mini-high",
          "openai/chatgpt-4o-latest", -- $5/15
          "openai/gpt-4.5-preview", -- $75/150
        },
        topic = {
          model = "anthropic/claude-3.7-sonnet",
          params = { max_completion_tokens = 10000 },
        },
        params = {
          chat = { temperature = 1.1, top_p = 1 },
          command = { temperature = 1.1, top_p = 1 },
        },
      },
      --openai = {
      --  api_key = os.getenv "OPENAI_API_KEY",
      --},
      --anthropic = {
      --  api_key = os.getenv "ANTHROPIC_API_KEY",
      --},
      --gemini = {
      --  api_key = os.getenv "GEMINI_API_KEY",
      --},
      --github = {
      --  api_key = os.getenv "GITHUB_TOKEN",
      --},
      --xai = {
      --  api_key = os.getenv "XAI_API_KEY",
      --},
    },
    -- Chat user prompt prefix
    chat_user_prefix = "🗨:",
    -- llm prompt prefix
    llm_prefix = "🦜:",
    -- Prompt used for interactive LLM calls like PrtRewrite where {{llm}} is
    -- a placeholder for the llm name🤖
    command_prompt_prefix_template = "🦜{{llm}} ~ ",
    toggle_target = "vsplit",
    online_model_selection = true,
    command_auto_select_response = false,
    hooks = {
      Complete = function(prt, params)
        local template = [[
        I have the following code from {{filename}}:

        ```{{filetype}}
        {{selection}}
        ```

        Please finish the code above carefully and logically.
        Respond just with the snippet of code that should be inserted."
        ]]
        local model_obj = prt.get_model "command"
        prt.Prompt(params, prt.ui.Target.append, model_obj, nil, template)
      end,
      CompleteContext = function(prt, params)
        local template = [[
        I have the following code from {{filename}}:

        ```{{filetype}}
        {{functionbody}}
        ```

        Please look at the following section specifically:
        ```{{filetype}}
        {{selection}}
        ```

        Please complete the remaining part of the code above,
        only output the newly added code.
        ]]
        local func_text = get_current_function()
        if func_text ~= nil then
          local t = template:gsub("{{functionbody}}", func_text)
          local model_obj = prt.get_model("command")
          -- hack. remove extra indent.
          -- lua/parrot/chat_handler.lua:1276
          params.range = 1
          prt.Prompt(params, prt.ui.Target.append, model_obj, nil, t)
        else
          require('notify').notify("Function definition/item/declaration not found", "", {title = "parrot"})
          return
        end
      end,
      CompleteFullContext = function(prt, params)
        local template = [[
        I have the following code from {{filename}}:

        ```{{filetype}}
        {{filecontent}}
        ```

        Please look at the following section specifically:
        ```{{filetype}}
        {{selection}}
        ```

        Please finish the code above carefully and logically.
        Respond just with the snippet of code that should be inserted.
        ]]
        local model_obj = prt.get_model("command")
        prt.Prompt(params, prt.ui.Target.append, model_obj, nil, template)
      end,
      CodeConsultant = function(prt, params)
        local chat_prompt = [[
        Your task is to analyze the provided {{filetype}} code and suggest
        improvements to optimize its performance. Identify areas where the
        code can be made more efficient, faster, or less resource-intensive.
        Provide specific suggestions for optimization, along with explanations
        of how these changes can enhance the code's performance. The optimized
        code should maintain the same functionality as the original code while
        demonstrating improved efficiency.

        Here is the code
        ```{{filetype}}
        {{selection}}
        ```
        ]]
        prt.ChatNew(params, chat_prompt)
      end,
      Explain = function(prt, params)
        local template = [[
        Your task is to take the code snippet from {{filename}} and explain it with gradually increasing complexity.
        Break down the code's functionality, purpose, and key components.
        The goal is to help the reader understand what the code does and how it works.

        ```{{filetype}}
        {{selection}}
        ```

        Use the markdown format with codeblocks and inline code.
        Explanation of the code above.
        Respond with the lang/locale: {{lang}}
        ]]
        local t = template:gsub("{{lang}}", vim.fn.environ()["LANG"])
        local model = prt.get_model "command"
        prt.logger.info("Explaining selection with model: " .. model.name)
        prt.Prompt(params, prt.ui.Target.vnew, model, nil, t)
      end,
      FixBugs = function(prt, params)
        local template = [[
        You are an expert in {{filetype}}.
        Fix bugs in the below code from {{filename}} carefully and logically:
        Your task is to analyze the provided {{filetype}} code snippet, identify
        any bugs or errors present, and provide a corrected version of the code
        that resolves these issues. Explain the problems you found in the
        original code and how your fixes address them. The corrected code should
        be functional, efficient, and adhere to best practices in
        {{filetype}} programming.

        ```{{filetype}}
        {{selection}}
        ```

        Fixed code:
        ]]
        local model_obj = prt.get_model "command"
        prt.logger.info("Fixing bugs in selection with model: " .. model_obj.name)
        prt.Prompt(params, prt.ui.Target.vnew, model_obj, nil, template)
      end,
      Optimize = function(prt, params)
        local template = [[
        You are an expert in {{filetype}}.
        Your task is to analyze the provided {{filetype}} code snippet and
        suggest improvements to optimize its performance. Identify areas
        where the code can be made more efficient, faster, or less
        resource-intensive. Provide specific suggestions for optimization,
        along with explanations of how these changes can enhance the code's
        performance. The optimized code should maintain the same functionality
        as the original code while demonstrating improved efficiency.

        ```{{filetype}}
        {{selection}}
        ```

        Optimized code:
        ]]
        local model_obj = prt.get_model "command"
        prt.logger.info("Optimizing selection with model: " .. model_obj.name)
        prt.Prompt(params, prt.ui.Target.vnew, model_obj, nil, template)
      end,
      Debug = function(prt, params)
        local template = [[
        I want you to act as {{filetype}} expert.
        Review the following code, carefully examine it, and report potential
        bugs and edge cases alongside solutions to resolve them.
        Keep your explanation short and to the point:

        ```{{filetype}}
        {{selection}}
        ```
        ]]
        local model_obj = prt.get_model "command"
        prt.logger.info("Debugging selection with model: " .. model_obj.name)
        prt.Prompt(params, prt.ui.Target.enew, model_obj, nil, template)
      end,
      CommitMsg = function(prt, params)
        local futils = require "parrot.file_utils"
        if futils.find_git_root() == "" then
          prt.logger.warning "Not in a git repository"
          return
        else
          local template = [[
          I want you to act as a commit message generator. I will provide you
          with information about the task and the prefix for the task code, and
          I would like you to generate an appropriate commit message using the
          conventional commit format. Do not write any explanations or other
          words, just reply with the commit message.
          Start with a short headline as summary but then list the individual
          changes in more detail.

          Here are the changes that should be considered by this message:
          ]] .. vim.fn.system "git diff --no-color --no-ext-diff --staged"
          local model_obj = prt.get_model "command"
          prt.Prompt(params, prt.ui.Target.append, model_obj, nil, template)
        end
      end,
    },
    keys = {
      { "<C-g>s", "<cmd>PrtStop<cr>", mode = { "n", "i", "v", "x" }, desc = "Stop" },
      {
        "<C-g>i",
        ":<C-u>'<,'>PrtComplete<cr>",
        mode = { "n", "i", "v", "x" },
        desc = "Complete visual selection",
      },
      { "<C-g>x", "<cmd>PrtContext<cr>", mode = { "n" }, desc = "Open context file" },
      { "<C-g>n", "<cmd>PrtModel<cr>", mode = { "n" }, desc = "Select model" },
      { "<C-g>p", "<cmd>PrtProvider<cr>", mode = { "n" }, desc = "Select provider" },
      { "<C-g>q", "<cmd>PrtAsk<cr>", mode = { "n" }, desc = "Ask a question" },
    },
  },
}
