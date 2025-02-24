return {
  {
    "zbirenbaum/copilot.lua",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<C-i>",
          accept_word = false,
          accept_line = false,
          next = "<C-.>",
          prev = "<C-m>",
          dismiss = "<C-,>",
        },
      },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
      },
      copilot_node_command = "/Users/alex/.nvm/versions/node/v20.17.0/bin/node",
    },
  },
}
