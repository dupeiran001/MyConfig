local wk = require("which-key")

local mappings = {
  { "<leader>tb", "<cmd>Obsidian backlinks<CR>", desc = "Fzf backlinks" },
  { "<leader>tn", "<cmd>Obsidian new<CR>",       desc = "Create new Obsidian note" },
  { "<leader>tr", "<cmd>Obsidian rename<CR>",    desc = "Rename current file" }
}

-- Set the options for which-key
local opts = {
  mode = "n", -- Normal mode
  prefix = "<leader>",
  buffer = 0, -- Buffer-local mappings
  silent = true,
  noremap = true,
  nowait = true,
}

-- Register the keymaps
wk.add(mappings, opts)
