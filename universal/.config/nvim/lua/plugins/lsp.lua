return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      servers = {
        eslint = {
          settings = {
            workingDirectories = { mode = "auto" },
            useFlatConfig = false,
            format = false,
            nodePath = vim.env.HOME .. "/.nvm/versions/node/v22.18.0/",
            -- options = {
            --   resolvePluginsRelativeTo = vim.env.HOME .. "/.nvm/versions/node/v22.18.0/lib/node_modules",
            -- },
            codeAction = {
              disableRuleComment = {
                enable = true,
                location = "separateLine",
              },
              showDocumentation = {
                enable = true,
              },
            },
          },
          root_dir = function(bufnr, on_dir)
            local util = require("lspconfig.util")

            local fname = vim.api.nvim_buf_get_name(bufnr)

            local eslintrc_root = util.root_pattern(".eslintrc.js", ".eslintrc")(fname)
            if eslintrc_root then
              on_dir(eslintrc_root)
            end

            -- Fallback to cwd
            local cwd = vim.fn.getcwd()
            on_dir(cwd)
          end,
        },
        vtsls = {
          root_dir = function()
            local lazyvimRoot = require("lazyvim.util.root")
            return lazyvimRoot.git()
          end,
          autoUseWorkspaceTsdk = true,
          settings = {
            typescript = {
              tsserver = {
                -- log = "verbose",
                maxTsServerMemory = 8192,
              },
              disableAutomaticTypeAcquisition = true,
              validate = {
                enable = false,
              },
            },
          },
        },
      },
      setup = {
        eslint = function()
          local formatter = LazyVim.lsp.formatter({
            name = "eslint: lsp",
            primary = false,
            priority = 200,
            filter = "eslint",
          })

          -- register the formatter with LazyVim
          LazyVim.format.register(formatter)

          Snacks.util.lsp.on({ name = "eslint" }, function(buffer, client)
            client.server_capabilities.documentFormattingProvider = true
          end)
          Snacks.util.lsp.on({ name = "tsserver" }, function(buffer, client)
            client.server_capabilities.documentFormattingProvider = false
          end)
        end,
      },
    },
  },
  {
    "yioneko/nvim-vtsls",
  },
}
