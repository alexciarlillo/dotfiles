return {
  "stevearc/oil.nvim",
  opts = {},
  lazy = false,
  keys = {
    {
      "<leader>fo",
      function()
        require("oil").open()
      end,
      desc = "Open Oil",
    },
  },
}
