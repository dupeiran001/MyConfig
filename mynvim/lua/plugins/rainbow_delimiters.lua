return {
  'HiPhish/rainbow-delimiters.nvim',
  dependencies = {"nvim-treesitter/nvim-treesitter"},
  opts = function()
    local rainbow_delimiters = require 'rainbow-delimiters'
    return {
    strategy = {
        [''] = rainbow_delimiters.strategy['global'],
        vim = rainbow_delimiters.strategy['local'],
    },
    query = {
        [''] = 'rainbow-delimiters',
        lua = 'rainbow-blocks',
    },
    priority = {
        [''] = 110,
        lua = 210,
    },
    highlight = {
        "RainbowDelimiterRed",
        "RainbowDelimiterYellow",
        "RainbowDelimiterBlue",
        "RainbowDelimiterOrange",
        "RainbowDelimiterGreen",
        "RainbowDelimiterPurple",
        "RainbowDelimiterCyan",
    }}
  end,
  config = function (_, opts)
    require("rainbow-delimiters.setup").setup(opts)
  end,
  init = function ()
    vim.api.nvim_set_hl(0, "RainbowDelimiterRed", {fg = "#BF616A"})
    vim.api.nvim_set_hl(0, "RainbowDelimiterYellow", {fg = "#EBCB8B"})
    vim.api.nvim_set_hl(0, "RainbowDelimiterBlue", {fg = "#81A1C1"})
    vim.api.nvim_set_hl(0, "RainbowDelimiterOrange", {fg = "#D08F70"})
    vim.api.nvim_set_hl(0, "RainbowDelimiterGreen", {fg = "#A3BE8C"})
    vim.api.nvim_set_hl(0, "RainbowDelimiterPurple", {fg = "#B48EAD"})
    vim.api.nvim_set_hl(0, "RainbowDelimiterCyan", {fg = "#88C0D0"})
  end
}
