return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-neotest/neotest-jest",
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-jest")({
          -- jestCommand = "npm run dev-test --",
          isTestFile = require("neotest-jest.jest-util").defaultIsTestFile,
        }),
      },
    })
  end,
  keys = {
    {
      "<leader>rt",
      function()
        require("neotest").run.run()
      end,
      desc = "Run Test",
    },
    {
      "<leader>rf",
      function()
        require("neotest").run.run((vim.fn.expand("%")))
      end,
      desc = "Run File Tests",
    },
    {
      "<leader>ro",
      function()
        require("neotest").output.open({ enter = true, auto_close = true })
      end,
      desc = "Run File Tests",
    },
  },
}
