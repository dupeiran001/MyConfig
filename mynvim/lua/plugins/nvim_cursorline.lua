return {
  "ya2s/nvim-cursorline",
  lazy = false,
  opts = {
    cursorline = {
      enable = false,
      timeout = 1000,
      number = false,
    },
    cursorword = {
      enable = true,
      min_length = 3,
      hl = { underline = true, bold = true, italic = true },
    }
  }
}
