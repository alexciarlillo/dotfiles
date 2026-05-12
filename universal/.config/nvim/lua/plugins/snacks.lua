return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    image = {
      enabled = false,
    },
  },
  keys = {
    {
      "<leader>gd",
      function()
        if next(require("diffview.lib").views) == nil then
          vim.cmd("DiffviewOpen")
        else
          vim.cmd("DiffviewClose")
        end
      end,
      desc = "Diff",
    },
    {
      "<leader>gD",
      function()
        if next(require("diffview.lib").views) == nil then
          vim.cmd("DiffviewOpen origin/HEAD...HEAD")
        else
          vim.cmd("DiffviewClose")
        end
      end,
      desc = "Diff Origin",
    },
  },
}
