return {
  {
    -- "folke/sidekick.nvim",
    "alexciarlillo/sidekick.nvim",
    branch = "feat/absolute-paths",
    opts = {
      cli = {
        mux = {
          backend = "tmux",
          enabled = true,
        },
        absolute_paths = true,
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
