return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      servers = {
        vtsls = {
          root_dir = function()
            local lazyvimRoot = require("lazyvim.util.root")
            return lazyvimRoot.git()
          end,
          autoUseWorkspaceTsdk = false,
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
