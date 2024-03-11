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
    vim.api.nvim_feedkeys(":q", "n", false)
  end,
})

-- FIXME only map esc to q in main page
-- -- map esc to q in normal mode in lazygit
-- vim.api.nvim_create_autocmd("TermOpen", {
--   pattern = { "term://*lazygit" },
--   callback = function()
--     vim.api.nvim_buf_set_keymap(0, "t", "<Esc>", "q", { silent = true })
--   end
-- })

-- auto format on save
local auto_fmt_id = nil
vim.api.nvim_create_user_command('AutoFormatToggle', function()
  if auto_fmt_id == nil then
    -- not enabled
    auto_fmt_id = vim.api.nvim_create_autocmd({ "BufWritePre" }, {
      pattern = "*",
      callback = function()
        local res = pcall(vim.lsp.buf.format, { async = false })
        print(res)
      end,
    })
    print("Auto Format Enabled")
  else
    -- enabled
    vim.api.nvim_del_autocmd(auto_fmt_id)
    auto_fmt_id = nil
    print("Auto Format Disabled")
  end
end, {})

-- Format on save enabled by default
auto_fmt_id = vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = "*",
  callback = function()
    local res = pcall(vim.lsp.buf.format, { async = false })
    print(res)
  end,
})
