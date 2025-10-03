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
          next = "<C-l>",
          prev = "<C-j>",
          dismiss = "<C-,>",
        },
      },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
      },
      copilot_node_command = "/Users/alex/.nvm/versions/node/v22.18.0/bin/node",
    },
  },
}
