return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        keymap = {
          accept = "<C-i>",
          accept_word = false,
          accept_line = false,
          next = "<C-.>",
          prev = "<C-m>",
          dismiss = "<C-,>",
        },
      },
      panel = { enabled = true, keymap = { open = "<C-;>" }, layout = {
        ratio = 0.3,
      } },
      filetypes = {
        markdown = true,
        help = true,
      },
      copilot_node_command = "/Users/alex/.nvm/versions/node/v20.17.0/bin/node",
    },
    keys = {
      {
        "<leader>as",
        "<cmd>Copilot<cr>",
        desc = "Copilot Start",
      },
    },
  },
}
