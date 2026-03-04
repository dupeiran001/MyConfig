return {
	"mason-org/mason-lspconfig.nvim",
	dependencies = {
		"mason-org/mason.nvim",
		"neovim/nvim-lspconfig",
		"saghen/blink.cmp",
	},
	event = { "BufReadPre", "BufNewFile" },
	lazy = true,
	opts = {
		ensure_installed = { "lua_ls", "rust_analyzer", "clangd", "bashls", "cmake", "marksman", "pyright", "taplo" },
	},
	config = function(_, opts)
		local capabilities = require("blink.cmp").get_lsp_capabilities()

		-- Apply completion capabilities to all servers configured via `vim.lsp.config`.
		vim.lsp.config("*", {
			capabilities = capabilities,
		})

		vim.lsp.config("lua_ls", {
			on_init = function(client)
				local workspace = client.workspace_folders and client.workspace_folders[1]
				local path = workspace and workspace.name
				local uv = vim.uv or vim.loop
				if path and uv and (uv.fs_stat(path .. "/.luarc.json") or uv.fs_stat(path .. "/.luarc.jsonc")) then
					return
				end

				client.config.settings = client.config.settings or {}
				client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua or {}, {
					runtime = {
						version = "LuaJIT",
					},
					workspace = {
						checkThirdParty = false,
						library = {
							vim.env.VIMRUNTIME,
						},
					},
				})
			end,
			settings = {
				Lua = {},
			},
		})

		require("mason-lspconfig").setup(opts)
	end,
}
