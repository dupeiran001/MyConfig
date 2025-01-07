return {
  'neovim/nvim-lspconfig',
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
    { "gd",    function() vim.lsp.buf.definition() end,      desc = "Goto Definition" },
    { "gD",    function() vim.lsp.buf.declaration() end,     desc = "Goto Declaration" },
    { "gr",    "<cmd>FzfLua lsp_references<cr>",             desc = "Goto Reference" },
    { "gI",    function() vim.lsp.buf.implementation() end,  desc = "Goto Implementation" },
    { "gy",    function() vim.lsp.buf.type_definition() end, desc = "Goto Type Definition" },
    { "gK",    function() vim.lsp.buf.signature_help() end,  desc = "Signiture Help" },
    { "ga",    "<cmd>FzfLua lsp_finder<cr>",                 desc = "FzfLua LspFinder" },
    { "K",     function() vim.lsp.buf.hover() end,           desc = "Hover" },
    { "<c-k>", function() vim.lsp.buf.hover() end,           desc = "Hover",               mode = "i" },
  }
}
