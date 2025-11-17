-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--

vim.opt.swapfile = false
vim.opt.clipboard = "unnamedplus"
vim.opt.autoindent = false
vim.opt.smartindent = false
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

vim.api.nvim_create_user_command("DebugEslint", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local fname = vim.api.nvim_buf_get_name(bufnr)

  print("Buffer: " .. bufnr)
  print("File: " .. fname)
  print("Filetype: " .. vim.bo.filetype)

  -- Check if eslint should attach to this filetype
  local eslint_filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "html" }
  local should_attach = vim.tbl_contains(eslint_filetypes, vim.bo.filetype)
  print("Should attach: " .. tostring(should_attach))

  -- Check active clients
  local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
  print("Active LSP clients:")
  for _, client in pairs(clients) do
    print("  - " .. client.name)
  end

  -- Try to get eslint config
  local lspconfig = require("lspconfig")
  local configs = require("lspconfig.configs")

  if configs.eslint then
    print("\nESLint config exists")
    local config = configs.eslint
    print("Cmd: " .. vim.inspect(config.cmd))
    print("Filetypes: " .. vim.inspect(config.filetypes))
  end
end, {})

vim.api.nvim_create_user_command("StartEslint", function()
  local lspconfig = require("lspconfig")
  lspconfig.eslint.setup({
    root_dir = function(fname)
      local util = require("lspconfig.util")
      return util.root_pattern(".eslintrc.js", ".eslintrc")(fname) or vim.fn.getcwd()
    end,
    settings = {
      workingDirectories = { mode = "location" },
      useFlatConfig = false,
      format = true,
      nodePath = vim.env.HOME .. "/.nvm/versions/node/v22.18.0",
      packageManager = "npm",
      options = {
        resolvePluginsRelativeTo = vim.env.HOME .. "/.nvm/versions/node/v22.18.0/lib/node_modules",
      },
    },
  })
  vim.cmd("LspStart eslint")
  print("Attempted to start ESLint LSP")
end, {})
