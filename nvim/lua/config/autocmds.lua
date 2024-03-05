-- make neo tree not scrollable
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = { "neo-tree*" },
  callback = function()
    vim.b.sidescroll = 0
  end,
})

-- auto close terminal when :wqa
vim.api.nvim_create_autocmd({ "BufWriteCmd" }, {
  pattern = { "term://*" },
  callback = function()
    print("toggleterm write")
    vim.api.nvim_feedkeys(":q", "n", false)
  end,
})

-- auto format on save
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = "*",
  callback = function()
    local res = pcall(vim.lsp.buf.format, { async = false })
    print(res)
  end,
})
