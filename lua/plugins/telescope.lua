table.unpack = table.unpack or unpack -- 5.1 compatibility

local config = {
  grep_hidden = true,
  fzf_native = true,
  show_untracked_files = false,
  keys = {
    -- Search stuff
    { "<leader>sc", "<cmd>Telescope commands<cr>", desc = "Commands" },
    { "<leader>ss", "<cmd>Telescope live_grep<cr>", desc = "Strings" },
    { "<leader>s?", "<cmd>Telescope help_tags<cr>", desc = "Help" },
    { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
    { "<leader>sO", "<cmd>Telescope vim_options<cr>", desc = "Vim Options" },
    { "<leader>sR", "<cmd>Telescope registers<cr>", desc = "Registers" },
    { "<leader>ag", "<cmd>Telescope grep_string<cr>", desc = "Word under cursor" },
    { "<leader>sS", "<cmd>Telescope symbols<cr>", desc = "Emoji" },
    { "<leader>s:", "<cmd>Telescope search_history<cr>", desc = "Search History" },
    { "<leader>s;", "<cmd>Telescope command_history<cr>", desc = "Command history" },
    {
      "<leader>sW",
      "<cmd>lua require'telescope.builtin'.grep_string{ shorten_path = true, word_match = '-w', only_sort_text = true, search = '' }<cr>",
      desc = "Word search",
    },
    -- Git
    { "<leader>tb", "<cmd>Telescope git_branches<cr>", desc = "Branches" },
    { "<leader>ts", "<cmd>Telescope git_status<cr>", desc = "Status" },
    { "<leader>tc", "<cmd>Telescope git_commits<cr>", desc = "Commits" },
    -- files
    { "<C-f>", "<cmd>Telescope find_files<cr>", desc = "Open file (ignore git)" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
    -- misc
    { "<leader>mt", "<cmd>Telescope<cr>", desc = "Telescope" },
    -- Other
    { "<leader>bf", "<cmd>Telescope buffers<cr>", desc = "Bufferlist" },
    -- { "<C-f>", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search in buffer" },
  },
  config_function = function(opts)
    require("telescope").setup(opts)
  end,
  opts = {
    pickers = {
      find_files = {
        hidden = false,
      },
      oldfiles = {
        cwd_only = true,
      },
      buffers = {
        ignore_current_buffer = true,
        sort_lastused = true,
      },
      live_grep = {
        only_sort_text = true, -- grep for content and not file name/path
      },
    },
    defaults = {
      file_ignore_patterns = {
        "%.7z",
        "%.avi",
        "%.JPEG",
        "%.JPG",
        "%.V",
        "%.RAF",
        "%.burp",
        "%.bz2",
        "%.cache",
        "%.class",
        "%.dll",
        "%.docx",
        "%.dylib",
        "%.epub",
        "%.exe",
        "%.flac",
        "%.ico",
        "%.ipynb",
        "%.jar",
        "%.jpeg",
        "%.jpg",
        "%.lock",
        "%.mkv",
        "%.mov",
        "%.mp4",
        "%.otf",
        "%.pdb",
        "%.pdf",
        "%.png",
        "%.rar",
        "%.sqlite3",
        "%.svg",
        "%.tar",
        "%.tar.gz",
        "%.ttf",
        "%.webp",
        "%.zip",
        ".git/",
        ".gradle/",
        ".idea/",
        ".vale/",
        ".vscode/",
        "__pycache__/*",
        "build/",
        "env/",
        "gradle/",
        "node_modules/",
        "smalljre_*/*",
        "target/",
        "vendor/*",
        "tags",
      },
      layout_strategy = "flex",
      layout_config = {
        horizontal = {
          prompt_position = "top",
          preview_width = 0.55,
        },
        vertical = {
          mirror = false,
        },
        width = 0.87,
        height = 0.80,
        preview_cutoff = 120,
      },
      results_title = false,
      winblend = 0, -- transparency
      borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      set_env = { ["COLORTERM"] = "truecolor" },
    },
  },
}

return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    enabled = true,
    dependencies = {
      { "telescope-fzf-native.nvim", optional = true },
    },
    keys = config.keys,
    opts = config.opts,
    config = function(_, opts)
      config.config_function(opts)
    end,
  },

  {
    "nvim-telescope/telescope-fzf-native.nvim",
    enabled = config.fzf_native,
    build = "make",
    lazy = "true",
    config = function()
      require("telescope").load_extension("fzf")
    end,
  },

  {
    "jvgrootveld/telescope-zoxide", -- TODO: configurable
    config = function()
      require("telescope").load_extension("zoxide")
    end,
    keys = {
      { "<leader>fz", "<cmd>Telescope zoxide list<cr>", desc = "Zoxide" },
    },
  },

  {
    "crispgm/telescope-heading.nvim",
    config = function()
      require("telescope").load_extension("heading")
    end,
    keys = {
      { "<leader>sh", "<cmd>Telescope heading<cr>", desc = "Headings" },
    },
  },
}
