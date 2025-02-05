return {
	"neovim/nvim-lspconfig",
	dependencies = "ibhagwan/fzf-lua",
	config = function()
		-- we want to automatically setup lsp in mason_lspconfig hook
		local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
		end
	end,
	keys = {
		{
			"gd",
			--- check the number of definition, if one, just jump to it, or use fzf_lua
			function()
				-- vim.lsp.buf.definition()
				local params = vim.lsp.util.make_position_params()
				vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result, ctx, _)
					if err or not result or vim.tbl_isempty(result) then
						vim.notify("No definitions found.", vim.log.levels.INFO)
						return
					end
					if #result == 1 then
						-- Navigate to the single definition
						vim.lsp.util.jump_to_location(result[1], "utf-8", true)
					else
						-- Use fzf-lua to present multiple definitions
						require("fzf-lua").lsp_definitions()
					end
				end)
			end,
			desc = "Goto Definition",
		},
		{
			"gD",
			function()
				-- vim.lsp.buf.declaration()

				local params = vim.lsp.util.make_position_params()
				vim.lsp.buf_request(0, "textDocument/declaration", params, function(err, result, ctx, _)
					if err or not result or vim.tbl_isempty(result) then
						vim.notify("No declarations found.", vim.log.levels.INFO)
						return
					end
					if #result == 1 then
						-- Navigate to the single declaration
						vim.lsp.util.jump_to_location(result[1], "utf-8", true)
					else
						-- Use fzf-lua to present multiple declarations
						require("fzf-lua").lsp_declarations()
					end
				end)
			end,
			desc = "Goto Declaration",
		},
		{
			"gr",
			function()
				-- "<cmd>FzfLua lsp_references<cr>"
				local params = vim.lsp.util.make_position_params()
				vim.lsp.buf_request(0, "textDocument/references", params, function(err, result, ctx, _)
					if err or not result or vim.tbl_isempty(result) then
						vim.notify("No references found.", vim.log.levels.INFO)
						return
					end
					if #result == 1 then
						-- Navigate to the single reference
						vim.lsp.util.jump_to_location(result[1], "utf-8", true)
					else
						-- Use fzf-lua to present multiple references
						require("fzf-lua").lsp_references()
					end
				end)
			end,
			desc = "Goto Reference",
		},
		{
			"gI",
			function()
				-- vim.lsp.buf.implementation()
				local params = vim.lsp.util.make_position_params()
				vim.lsp.buf_request(0, "textDocument/implementation", params, function(err, result, ctx, _)
					if err or not result or vim.tbl_isempty(result) then
						vim.notify("No implementations found.", vim.log.levels.INFO)
						return
					end
					if #result == 1 then
						-- Navigate to the single implementation
						vim.lsp.util.jump_to_location(result[1], "utf-8", true)
					else
						-- Use fzf-lua to present multiple implementations
						require("fzf-lua").lsp_implementations()
					end
				end)
			end,
			desc = "Goto Implementation",
		},
		{
			"gy",
			function()
				-- vim.lsp.buf.type_definition()
				local params = vim.lsp.util.make_position_params()
				vim.lsp.buf_request(0, "textDocument/typeDefinition", params, function(err, result, ctx, _)
					if err or not result or vim.tbl_isempty(result) then
						vim.notify("No type definitions found.", vim.log.levels.INFO)
						return
					end
					if #result == 1 then
						-- Navigate to the single type definition
						vim.lsp.util.jump_to_location(result[1], "utf-8", true)
					else
						-- Use fzf-lua to present multiple type definitions
						require("fzf-lua").lsp_typedefs()
					end
				end)
			end,
			desc = "Goto Type Definition",
		},
		{
			"gK",
			function()
				vim.lsp.buf.signature_help()
			end,
			desc = "Signiture Help",
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
