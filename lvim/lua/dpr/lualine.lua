-- stylua: ignore
local colors = {
  blue   = '#80a0ff',
  cyan   = '#79dac8',
  black  = '#080808',
  white  = '#c6c6c6',
  red    = '#ff5189',
  violet = '#d183e8',
  grey   = '#303030',
}

local bubbles_theme = {
  normal = {
    a = { fg = colors.black, bg = colors.violet },
    b = { fg = colors.white, bg = colors.grey },
    c = { fg = colors.black, bg = colors.black },
  },

  insert = { a = { fg = colors.black, bg = colors.blue } },
  visual = { a = { fg = colors.black, bg = colors.cyan } },
  replace = { a = { fg = colors.black, bg = colors.red } },

  inactive = {
    a = { fg = colors.white, bg = colors.black },
    b = { fg = colors.white, bg = colors.black },
    c = { fg = colors.black, bg = colors.black },
  },
}

lvim.builtin.lualine.options.theme = 'nord'
--lvim.builtin.lualine.options.component_separators = { left = '', right = '' }
lvim.builtin.lualine.options.section_separators = { left = '', right = '' }
lvim.builtin.lualine.options.component_separators = '|'
lvim.builtin.lualine.style = "default"

lvim.builtin.lualine.sections.lualine_a = { { 'mode', separator = { left = '' }, right_padding = 2 } }
lvim.builtin.lualine.sections.lualine_z = {
  { 'location', separator = { right = '' }, left_padding = 2 }

}
