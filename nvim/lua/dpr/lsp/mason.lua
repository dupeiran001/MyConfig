
local servers = {
  "lua_ls",
	"pyright",
	"jsonls",
  "rust_analyzer"
}

local settings = {
	ui = {
		border = "none",
		icons = {
			package_installed = "◍",
			package_pending = "◍",
			package_uninstalled = "◍",
		},
	},
	log_level = vim.log.levels.INFO,
	max_concurrent_installers = 4,
}

require("mason").setup(settings)
require("mason-lspconfig").setup({
	ensure_installed = servers,
	automatic_installation = true,
})

local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
  vim.notify "lspconfig not found"
	return
end

local opts = {}

for _, server in pairs(servers) do
	opts = {
		on_attach = require("dpr.lsp.handlers").on_attach,
		capabilities = require("dpr.lsp.handlers").capabilities,
	}

	  server = vim.split(server, "@")[1]

  	local require_ok, conf_opts = pcall(require, "dpr.lsp.settings." .. server)
  	if require_ok then
  		opts = vim.tbl_deep_extend("force", opts, conf_opts)
  	end
  	lspconfig[server].setup(opts)
end
