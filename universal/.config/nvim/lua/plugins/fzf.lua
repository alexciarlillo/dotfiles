return {
  {
    "ibhagwan/fzf-lua",
    keys = {
      { "<leader><space>", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
    },
    opts = function(_, opts)
      local fzf = require("fzf-lua")
      local actions = fzf.actions

      opts.files.actions = {
        ["ctrl-h"] = actions.toggle_hidden,
        ["ctrl-i"] = actions.toggle_ignore,
      }

      opts.grep.actions = {
        ["ctrl-h"] = actions.toggle_hidden,
        ["ctrl-i"] = actions.toggle_ignore,
      }

      opts.previewers.builtin = vim.tbl_deep_extend("force", opts.previewers.builtin or {}, {
        snacks_image = { enabled = false },
      })
    end,
  },
}
