focus_window = function()
  local window = require("window-picker").pick_window()
  vim.api.nvim_set_current_win(window)
end

return {
  {
    "s1n7ax/nvim-window-picker",
    name = "window-picker",
    event = "VeryLazy",
    version = "2.*",
    config = function()
      require("window-picker").setup({ hint = "floating-big-letter" })
    end,
    keys = {
      {
        "<leader>wf",
        focus_window,
        desc = "Focus Window",
      },
    },
  },
}
