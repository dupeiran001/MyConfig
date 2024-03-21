return {
  {
    "hrsh7th/nvim-cmp",
    version = false, -- last release is way too old
    -- keys = {
    --   { "<Tab>", false },
    -- },
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        --["<Tab>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
      })
    end,
  },
  -- {
  --   "L3MON4D3/LuaSnip",
  --   keys = function() end,
  -- },
}
