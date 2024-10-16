return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      servers = {
        ts_ls = {
          enabled = false,
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
                maxTsServerMemory = 4096,
                watchOptions = {
                  watchFile = "useFsEventsOnParentDirectory",
                  fallbackPolling = "dynamicPriorityPolling",
                },
              },
              disableAutomaticTypeAcquisition = true,
              validate = {
                enable = false,
              },
            },
          },
        },
      },
    },
  },
  {
    "yioneko/nvim-vtsls",
  },
}
