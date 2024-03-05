return  {
  'akinsho/toggleterm.nvim',
  keys = {
    { "<C-\\>", "<cmd>ToggleTerm<cr>", desc = "Terminal (toggle)" },
    { "<C-1>", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Terminal (vertical)" },
    { "<C-2>", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Find Files (horizonal)" },
    { "<C-3>", "<cmd>ToggleTerm direction=float<cr>", desc = "Find Files (float)" },
    { "<C-4>", "<cmd>ToggleTerm direction=tab<cr>", desc = "Find Files (tab)" },
  },

  opts = {--[[ things you want to change go here]]},
  config = function()
    require("toggleterm").setup({
      open_mapping = [[<C-\>]],
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.3
        end
      end,
      direction = "float",
      close_on_exit = true,
    })
  end
}
