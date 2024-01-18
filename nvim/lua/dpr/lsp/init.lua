local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  vim.notify "lspconfig not found"
  return
end

require "dpr.lsp.mason"
require("dpr.lsp.handlers").setup()
require "dpr.lsp.null-ls"
