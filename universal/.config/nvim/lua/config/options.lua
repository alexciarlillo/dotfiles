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

-- copy / paste SSH
vim.o.clipboard = "unnamedplus"
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    -- vim.highlight.on_yank()
    local copy_to_unnamedplus = require("vim.ui.clipboard.osc52").copy("+")
    copy_to_unnamedplus(vim.v.event.regcontents)
    local copy_to_unnamed = require("vim.ui.clipboard.osc52").copy("*")
    copy_to_unnamed(vim.v.event.regcontents)
  end,
})
