vim.keymap.set("n", "<cr>", "<Plug>(neorg.esupports.hop.hop-link)",
  { desc = "[neorg] Jump to Link", buffer = true })
vim.keymap.set("n", "<,", "<Plug>(neorg.promo.demote)",
  { desc = "[neorg] Demote Object (Non-Recursively)", buffer = true })
vim.keymap.set("n", "<<", "<Plug>(neorg.promo.demote.nested)",
  { desc = "[neorg] Demote Object (Recursively)", buffer = true })
vim.keymap.set("n", ">.", "<Plug>(neorg.promo.promote)",
  { desc = "[neorg] Promote Object (Non-Recursively)", buffer = true })
vim.keymap.set("n", ">>", "<Plug>(neorg.promo.promote.nested)",
  { desc = "[neorg] Promote Object (Recursively)", buffer = true })
