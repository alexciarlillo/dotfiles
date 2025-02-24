return {
  {
    "ibhagwan/fzf-lua",
    keys = {
      { "<leader><space>", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
    },
    opts = function(_, opts)
      local fzf = require("fzf-lua")
      local actions = fzf.actions

      return {
        files = {
          cwd_prompt = false,
          actions = {
            ["ctrl-h"] = { actions.toggle_hidden },
            ["ctrl-i"] = { actions.toggle_ignore },
          },
        },
        grep = {
          actions = {
            ["ctrl-h"] = { actions.toggle_hidden },
            ["ctrl-i"] = { actions.toggle_ignore },
          },
        },
      }
    end,
  },
}
