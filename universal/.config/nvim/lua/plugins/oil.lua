return {
  "stevearc/oil.nvim",
  opts = {},
  lazy = false,
  default_file_explorer = false,
  keys = {
    {
      "<leader>fo",
      function()
        require("oil").open_float()
      end,
      desc = "Open Oil",
    },
  },
}
