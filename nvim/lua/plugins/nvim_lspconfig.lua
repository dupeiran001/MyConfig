return {
	"neovim/nvim-lspconfig",
	config = function()
		vim.diagnostic.config({
			virtual_text = false,
			virtual_lines = { current_line = true },
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = "󰅚 ",
					[vim.diagnostic.severity.WARN] = "󰀪 ",
					[vim.diagnostic.severity.HINT] = "󰌶 ",
					[vim.diagnostic.severity.INFO] = " ",
				},
			},
		})
	end,
	keys = {
		{
			"gd",
			function()
				require("fzf-lua").lsp_definitions({ jump_to_single_result = true })
			end,
			desc = "Goto Definition",
		},
		{
			"gD",
			function()
				require("fzf-lua").lsp_declarations({ jump_to_single_result = true })
			end,
			desc = "Goto Declaration",
		},
		{
			"gr",
			function()
				require("fzf-lua").lsp_references({ jump_to_single_result = true })
			end,
			desc = "Goto Reference",
		},
		{
			"gI",
			function()
				require("fzf-lua").lsp_implementations({ jump_to_single_result = true })
			end,
			desc = "Goto Implementation",
		},
		{
			"gy",
			function()
				require("fzf-lua").lsp_typedefs({ jump_to_single_result = true })
			end,
			desc = "Goto Type Definition",
		},
		{
			"gK",
			function()
				vim.lsp.buf.signature_help()
			end,
			desc = "Signature Help",
		},
		{ "ga", "<cmd>FzfLua lsp_finder<cr>", desc = "FzfLua LspFinder" },
		{
			"K",
			function()
				vim.lsp.buf.hover()
			end,
			desc = "Hover",
		},
		{
			"<c-k>",
			function()
				vim.lsp.buf.hover()
			end,
			desc = "Hover",
			mode = "i",
		},
	},
}
