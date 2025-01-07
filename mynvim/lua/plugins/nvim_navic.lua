return {
  "SmiteshP/nvim-navic",
  lazy = true,
   dependencies = {"neovim/nvim-lspconfig"},
   opts = {
    icons = {
      File = "󰈙 ",
      Module = " ",
      Namespace = "󰌗 ",
      Package = " ",
      Class = "󰌗 ",
      Method = "󰆧 ",
      Property = " ",
      Field = " ",
      Constructor = " ",
      Enum = "󰕘 ",
      Interface = "󰕘 ",
      Function = "󰊕 ",
      Variable = "󰆧 ",
      Constant = "󰏿 ",
      String = "󰀬 ",
      Number = "󰎠 ",
      Boolean = "◩ ",
      Array = "󰅪 ",
      Object = " ",
      Key = "󰌋 ",
      Null = "󰟢 ",
      EnumMember = " ",
      Struct = "󰌗 ",
      Event = " ",
      Operator = "󰆕 ",
      TypeParameter = "󰊄 ",
    },
    lsp = {
      auto_attach = true,
      preference = nil,
    },
    highlight = true,
    separator = "  ",
    depth_limit = 0,
    depth_limit_indicator = "..",
    safe_output = true,
    lazy_update_context = true,
    click = true,
    format_text = function(text)
      return text
    end,
   },
  init = function ()
          -- navic highlights
      vim.api.nvim_set_hl(0, "NavicIconsFile", { default = false, bg = "#3b4252", fg = "#a3be8c" })
      vim.api.nvim_set_hl(0, "NavicIconsModule", { default = false, bg = "#3b4252", fg = "#b48ead" })
      vim.api.nvim_set_hl(0, "NavicIconsNamespace", { default = false, bg = "#3b4252", fg = "#b48ead" })
      vim.api.nvim_set_hl(0, "NavicIconsPackage", { default = false, bg = "#3b4252", fg = "#b48ead" })
      vim.api.nvim_set_hl(0, "NavicIconsClass", { default = false, bg = "#3b4252", fg = "#81a1c1" })
      vim.api.nvim_set_hl(0, "NavicIconsMethod", { default = false, bg = "#3b4252", fg = "#8fbcbb" })
      vim.api.nvim_set_hl(0, "NavicIconsProperty", { default = false, bg = "#3b4252", fg = "#b48ead" })
      vim.api.nvim_set_hl(0, "NavicIconsField", { default = false, bg = "#3b4252", fg = "#b48ead" })
      vim.api.nvim_set_hl(0, "NavicIconsConstructor", { default = false, bg = "#3b4252", fg = "#81a1c1" })
      vim.api.nvim_set_hl(0, "NavicIconsEnum", { default = false, bg = "#3b4252", fg = "#81a1c1" })
      vim.api.nvim_set_hl(0, "NavicIconsInterface", { default = false, bg = "#3b4252", fg = "#81a1c1" })
      vim.api.nvim_set_hl(0, "NavicIconsFunction", { default = false, bg = "#3b4252", fg = "#88c0d0" })
      vim.api.nvim_set_hl(0, "NavicIconsVariable", { default = false, bg = "#3b4252", fg = "#b48ead" })
      vim.api.nvim_set_hl(0, "NavicIconsConstant", { default = false, bg = "#3b4252", fg = "#ebcb8b" })
      vim.api.nvim_set_hl(0, "NavicIconsString", { default = false, bg = "#3b4252", fg = "#a3be8c" })
      vim.api.nvim_set_hl(0, "NavicIconsNumber", { default = false, bg = "#3b4252", fg = "#b48ead" })
      vim.api.nvim_set_hl(0, "NavicIconsBoolean", { default = false, bg = "#3b4252", fg = "#81a1c1" })
      vim.api.nvim_set_hl(0, "NavicIconsArray", { default = false, bg = "#3b4252", fg = "#ebcb8b" })
      vim.api.nvim_set_hl(0, "NavicIconsObject", { default = false, bg = "#3b4252", fg = "#81a1c1" })
      vim.api.nvim_set_hl(0, "NavicIconsKey", { default = false, bg = "#3b4252", fg = "#81a1c1" })
      vim.api.nvim_set_hl(0, "NavicIconsNull", { default = false, bg = "#3b4252", fg = "#81a1c1" })
      vim.api.nvim_set_hl(0, "NavicIconsEnumMember", { default = false, bg = "#3b4252", fg = "#b48ead" })
      vim.api.nvim_set_hl(0, "NavicIconsStruct", { default = false, bg = "#3b4252", fg = "#81a1c1" })
      vim.api.nvim_set_hl(0, "NavicIconsEvent", { default = false, bg = "#3b4252", fg = "#81a1c1" })
      vim.api.nvim_set_hl(0, "NavicIconsOperator", { default = false, bg = "#3b4252", fg = "#81a1c1" })
      vim.api.nvim_set_hl(0, "NavicIconsTypeParameter", { default = false, bg = "#3b4252", fg = "#5e81ac" })
      vim.api.nvim_set_hl(0, "NavicText", { default = false, bg = "#3b4252", fg = "#d8dee9" })
      vim.api.nvim_set_hl(0, "NavicSeparator", { default = false, bg = "#3b4252", fg = "#a3c9aa" })
  end
}
