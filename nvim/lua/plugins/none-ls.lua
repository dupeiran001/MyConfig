return {
  "nvimtools/none-ls.nvim",
  config = function()
    local null_ls = require("null-ls")

    local no_really = {
      method = null_ls.methods.DIAGNOSTICS,
      filetypes = { "markdown", "text" },
      generator = {
        fn = function(params)
            local diagnostics = {}
            -- sources have access to a params object
            -- containing info about the current file and editor state
            for i, line in ipairs(params.content) do
                local col, end_col = line:find("really")
                if col and end_col then
                    -- null-ls fills in undefined positions
                    -- and converts source diagnostics into the required format
                    table.insert(diagnostics, {
                        row = i,
                        col = col,
                        end_col = end_col + 1,
                        source = "no-really",
                        message = "Don't use 'really!'",
                        severity = vim.diagnostic.severity.WARN,
                    })
                end
            end
            return diagnostics
        end,
      },
    }
    null_ls.register(no_really)

    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
    require("null-ls").setup({
        -- you can reuse a shared lspconfig on_attach callback here
        on_attach = function(client, bufnr)
            if client.supports_method("textDocument/formatting") then
                vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
                vim.api.nvim_create_autocmd("BufWritePre", {
                    group = augroup,
                    buffer = bufnr,
                    callback = function()
                        -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
                        -- on later neovim version, you should use vim.lsp.buf.format({ async = false }) instead
                        vim.lsp.buf.formatting_sync()
                    end,
                })
            end
        end,
    })
  end
}
