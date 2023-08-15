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

return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-live-grep-args.nvim",
      config = function()
        require("telescope").load_extension("live_grep_args")
      end,
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
      { "<leader>sw", my_grep_word, desc = "Word (root dir git)" },
      { "<leader>sw", my_grep_word, mode = "v", desc = "Selection (root dir git)" },
    },
  },
}
