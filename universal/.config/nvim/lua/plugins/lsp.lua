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
    },
  },
  {
    "yioneko/nvim-vtsls",
  },
}
