return {
  "mrjones2014/nvim-ts-rainbow",
  config = function()
    require("nvim-treesitter.configs").setup {
      rainbow = {
        enable = true,
        extended_mode = true, -- Alo highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
      }
    }
  end
}
