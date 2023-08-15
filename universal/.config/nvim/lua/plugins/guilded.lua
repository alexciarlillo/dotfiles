return {
  {
    "guilded/import-under-cursor",
    -- dev = true,
    lazy = false,
    dir = os.getenv("GUILDED_ROOT_DIR") .. "/client/editor_tools/neovim/import-under-cursor",
    name = "import-under-cursor",
    keys = {
      {
        "<leader>ci",
        "<cmd>ImportUnderCursor<cr>",
        desc = "Import Under Cursor",
      },
    },
  },
}
