return {
  {
    "folke/sidekick.nvim",
    opts = {
      cli = {
        mux = {
          backend = "tmux",
          enabled = true,
        },
      },
      nes = {
        enabled = false,
      },
    },
    keys = {
      {
        "<leader>ac",
        function()
          require("sidekick.cli").toggle({ name = "cursor", focus = true })
        end,
        desc = "Sidekick Toggle Cursor",
      },
    },
  },
}
