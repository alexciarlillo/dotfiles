return {
  {
    "vincent178/nvim-github-linker",
    opts = {
      mappings = true,
      default_remote = "origin",
      copy_to_clipboard = true,
    },
    keys = {
      {
        "<leader>gy",
        "<cmd>GithubLink<cr>",
        desc = "Github Link",
      },
    },
  },
}
