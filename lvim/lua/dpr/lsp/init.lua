lvim.format_on_save.enabled = true

lvim.lsp.document_highlight = true

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(args.buf, true)
    end
    -- whatever other lsp config you want
  end
})

vim.tbl_extend("keep", lvim.builtin.cmp.sources, { name = "crates" })
