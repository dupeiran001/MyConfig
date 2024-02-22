vim.opt.clipboard = "unnamedplus"
vim.opt.fileencoding = "utf-8"

vim.opt.relativenumber = true
vim.opt.shiftwidth = 2
vim.opt.wrap = true

vim.opt.ignorecase = true
vim.opt.swapfile = false
vim.opt.tabstop = 2
vim.opt.numberwidth = 2

vim.cmd "set whichwrap+=<,>,[,],h,l"
vim.cmd [[set iskeyword+=-]]

vim.opt.foldmethod = "manual"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
