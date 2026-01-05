-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--

vim.opt.swapfile = false
vim.opt.clipboard = "unnamedplus"
vim.opt.autoindent = false
vim.opt.smartindent = false
vim.opt.winborder = "rounded"

vim.g.ai_cmp = false
vim.g.lazyvim_eslint_auto_format = true

-- vim.lsp.set_log_level("debug")

-- Set a specific Node.js version for all plugins
vim.env.NEOVIM_NODE_VERSION = "v22.18.0"
if vim.fn.has("unix") and vim.env.NEOVIM_NODE_VERSION then
  local node_dir = vim.env.HOME .. "/.nvm/versions/node/" .. vim.env.NEOVIM_NODE_VERSION .. "/bin/"
  if vim.fn.isdirectory(node_dir) then
    vim.env.PATH = node_dir .. ":" .. vim.env.PATH
  end
end
