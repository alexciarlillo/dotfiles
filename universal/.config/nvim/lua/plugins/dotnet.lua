return {
  {
    "GustavEikaas/easy-dotnet.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
    ft = { "cs", "csproj", "sln", "slnx", "props", "csx", "targets" },
    cmd = "Dotnet",
    config = function()
      require("easy-dotnet").setup({
        lsp = {
          enabled = false,
        },
        csproj_mappings = true,
        test_runner = {
          viewmode = "float",
          noBuild = false,
          noRestore = true,
          icons = {
            passed = "",
            skipped = "",
            failed = "",
            success = "",
            reload = "",
            test = "",
            sln = "󰘐",
            project = "󰘐",
            dir = "",
            package = "",
          },
        },
        ---@param action "test" | "restore" | "build" | "run"
        terminal = function(path, action, args)
          args = args or ""
          local commands = {
            run = function()
              return string.format("dotnet run --project %s %s", path, args)
            end,
            test = function()
              return string.format("dotnet test %s %s", path, args)
            end,
            restore = function()
              return string.format("dotnet restore %s %s", path, args)
            end,
            build = function()
              return string.format("dotnet build %s %s", path, args)
            end,
            watch = function()
              return string.format("dotnet watch --project %s %s", path, args)
            end,
          }
          local command = commands[action]()
          if require("easy-dotnet.extensions").isWindows() == true then
            command = command .. "\r"
          end
          vim.cmd("vsplit")
          vim.cmd("term " .. command)
        end,
        picker = "fzf",
        background_scanning = true,
      })
    end,
    keys = {
      {
        "<leader>t",
        "<cmd>Dotnet testrunner<cr>",
        desc = "Dotnet Test Runner",
      },
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        cs = { "csharpier" },
      },
      formatters = {
        csharpier = {
          command = "dotnet",
          args = { "csharpier" },
        },
      },
    },
  },
  { "Hoffs/omnisharp-extended-lsp.nvim", lazy = true },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "c_sharp" } },
  },
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = opts.sources or {}
      table.insert(opts.sources, nls.builtins.formatting.csharpier)
    end,
  },
}
