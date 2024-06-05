my_find = function(opts)
  opts = opts or {}
  opts.cwd = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  require("telescope.builtin").find_files(opts)
end

my_grep = function(opts)
  opts = opts or {}
  opts.cwd = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  require("telescope").extensions.live_grep_args.live_grep_args(opts)
end

my_grep_word = function(opts)
  opts = opts or { word_match = "-w" }
  opts.cwd = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  require("telescope.builtin").grep_string(opts)
end

my_client_quote = function(opts)
  require("telescope").extensions.live_grep_args.actions.quote_prompt({
    postfix = " --iglob **/client/**",
  })
end

return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-live-grep-args.nvim",
    },
    keys = {
      {
        "<leader><space>",
        my_find,
        desc = "Find Files (root dir git)",
      },
      {
        "<leader>sg",
        my_grep,
        desc = "Grep (root dir git)",
      },
      { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Current Buffer Fuzzy" },
      { "<leader>sw", my_grep_word, desc = "Word (root dir git)" },
      { "<leader>sw", my_grep_word, mode = "v", desc = "Selection (root dir git)" },
    },

    opts = function(_, opts)
      local lga_actions = require("telescope-live-grep-args.actions")

      opts.defaults = vim.tbl_deep_extend("force", opts.defaults, {
        mappings = {
          i = {
            ["<C-b>"] = function(...)
              return require("telescope.actions").delete_buffer(...)
            end,
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
            ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
            ["<C-c>"] = lga_actions.quote_prompt({ postfix = " --iglob **/{shared,client}/**" }),
            ["<C-s>"] = lga_actions.quote_prompt({ postfix = " --iglob **/{shared,server}/**" }),
          },
          n = {
            ["<C-b>"] = function(...)
              return require("telescope.actions").delete_buffer(...)
            end,
          },
        },
        layout_strategy = "flex",
        layout_config = {
          horizontal = {
            preview_width = 0.45,
          },
          vertical = {
            width = 0.9,
            height = 0.95,
            preview_height = 0.5,
            preview_cutoff = 0,
          },
          flex = {
            flip_columns = 140,
          },
        },
      })
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      telescope.load_extension("live_grep_args")
    end,
  },

  -- Configure LazyVim to use specific symbols for JS
  {
    "LazyVim/LazyVim",
    opts = {
      kind_filter = {
        javascript = {
          "Class",
          "Constructor",
          "Enum",
          "Field",
          "Function",
          "Interface",
          "Method",
          "Module",
          "Namespace",
          "Package",
          -- "Property", -- not useful and clutters results
          "Struct",
          "Trait",
        },
      },
    },
  },
}
