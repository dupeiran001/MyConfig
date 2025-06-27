return {
	"neovim/nvim-lspconfig",
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
				local current_bufnr = vim.api.nvim_get_current_buf()
				local clients = vim.lsp.get_clients({ bufnr = current_bufnr })

				if not clients or #clients == 0 then
					vim.notify("LSP: No active client for this buffer.", vim.log.levels.WARN)
					return
				end

				local client = clients[1] -- Use the first client
				local server_pos_encoding = client.offset_encoding

				local params = vim.lsp.util.make_position_params(nil, server_pos_encoding)
				vim.lsp.buf_request(current_bufnr, "textDocument/definition", params, function(err, result, _, _)
					if err or not result or vim.tbl_isempty(result) then
						vim.notify("LSP: No definitions found.", vim.log.levels.INFO)
						return
					end
					if #result == 1 then
						vim.lsp.util.show_document(result[1], server_pos_encoding, { focus = true })
					else
						require("fzf-lua").lsp_definitions()
					end
				end)
			end,
			desc = "Goto Definition",
		},
		{
			"gD",
			function()
				local current_bufnr = vim.api.nvim_get_current_buf()
				local clients = vim.lsp.get_clients({ bufnr = current_bufnr })

				if not clients or #clients == 0 then
					vim.notify("LSP: No active client for this buffer.", vim.log.levels.WARN)
					return
				end

				local client = clients[1]
				local server_pos_encoding = client.offset_encoding

				local params = vim.lsp.util.make_position_params(nil, server_pos_encoding)
				vim.lsp.buf_request(current_bufnr, "textDocument/declaration", params, function(err, result, _, _)
					if err or not result or vim.tbl_isempty(result) then
						vim.notify("LSP: No declarations found.", vim.log.levels.INFO)
						return
					end
					if #result == 1 then
						vim.lsp.util.show_document(result[1], server_pos_encoding, { focus = true })
					else
						require("fzf-lua").lsp_declarations()
					end
				end)
			end,
			desc = "Goto Declaration",
		},
		{
			"gr",
			function()
				local current_bufnr = vim.api.nvim_get_current_buf()
				local clients = vim.lsp.get_clients({ bufnr = current_bufnr })

				if not clients or #clients == 0 then
					vim.notify("LSP: No active client for this buffer.", vim.log.levels.WARN)
					return
				end

				local client = clients[1]
				local server_pos_encoding = client.offset_encoding

				local params = vim.lsp.util.make_position_params(nil, server_pos_encoding)
				vim.lsp.buf_request(current_bufnr, "textDocument/references", params, function(err, result, _, _)
					if err or not result or vim.tbl_isempty(result) then
						vim.notify("LSP: No references found.", vim.log.levels.INFO)
						return
					end
					if #result == 1 then
						vim.lsp.util.show_document(result[1], server_pos_encoding, { focus = true })
					else
						require("fzf-lua").lsp_references()
					end
				end)
			end,
			desc = "Goto Reference",
		},
		{
			"gI",
			function()
				local current_bufnr = vim.api.nvim_get_current_buf()
				local clients = vim.lsp.get_clients({ bufnr = current_bufnr })

				if not clients or #clients == 0 then
					vim.notify("LSP: No active client for this buffer.", vim.log.levels.WARN)
					return
				end

				local client = clients[1]
				local server_pos_encoding = client.offset_encoding

				local params = vim.lsp.util.make_position_params(nil, server_pos_encoding)
				vim.lsp.buf_request(current_bufnr, "textDocument/implementation", params, function(err, result, _, _)
					if err or not result or vim.tbl_isempty(result) then
						vim.notify("LSP: No implementations found.", vim.log.levels.INFO)
						return
					end
					if #result == 1 then
						vim.lsp.util.show_document(result[1], server_pos_encoding, { focus = true })
					else
						require("fzf-lua").lsp_implementations()
					end
				end)
			end,
			desc = "Goto Implementation",
		},
		{
			"gy",
			function()
				local current_bufnr = vim.api.nvim_get_current_buf()
				local clients = vim.lsp.get_clients({ bufnr = current_bufnr })

				if not clients or #clients == 0 then
					vim.notify("LSP: No active client for this buffer.", vim.log.levels.WARN)
					return
				end

				local client = clients[1]
				local server_pos_encoding = client.offset_encoding

				local params = vim.lsp.util.make_position_params(nil, server_pos_encoding)
				vim.lsp.buf_request(current_bufnr, "textDocument/typeDefinition", params, function(err, result, _, _)
					if err or not result or vim.tbl_isempty(result) then
						vim.notify("LSP: No type definitions found.", vim.log.levels.INFO)
						return
					end
					if #result == 1 then
						vim.lsp.util.show_document(result[1], server_pos_encoding, { focus = true })
					else
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
			desc = "Signature Help", -- Corrected typo
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
