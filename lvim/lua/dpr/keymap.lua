lvim.keys.normal_mode["<Tab>"] = "<C-w>w"

lvim.builtin.which_key.mappings["q"] = { "<cmd>BufferKill<CR>", "kill buffer" }
lvim.builtin.which_key.mappings["b"].b = nil
lvim.builtin.which_key.mappings["b"].p = { "<cmd>BufferLineCyclePrev<cr>", "Previous" }

lvim.builtin.which_key.mappings["t"] = {
  name = "Diagnostics",
  t = { "<cmd>TroubleToggle<cr>", "trouble" },
  w = { "<cmd>TroubleToggle workspace_diagnostics<cr>", "workspace" },
  d = { "<cmd>TroubleToggle document_diagnostics<cr>", "document" },
  q = { "<cmd>TroubleToggle quickfix<cr>", "quickfix" },
  l = { "<cmd>TroubleToggle loclist<cr>", "loclist" },
  r = { "<cmd>TroubleToggle lsp_references<cr>", "references" },
}

lvim.builtin.which_key.mappings["f"] = {
  name = "Telescope",
  f = { "<cmd>Telescope find_files<CR>", "file" },
  c = { "<cmd>Telescope live_grep<CR>", "code" },
  p = { "<cmd> Telescope projects<CR>", "projects" }
}

lvim.builtin.which_key.mappings["s"].t = nil
lvim.builtin.which_key.mappings["s"].c = nil
lvim.builtin.which_key.mappings["s"].name = nil
lvim.builtin.which_key.mappings["s"].f = nil
lvim.builtin.which_key.mappings["s"].p = nil

lvim.builtin.which_key.mappings["f"] =
    vim.tbl_extend("error", lvim.builtin.which_key.mappings["f"], lvim.builtin.which_key.mappings["s"])


lvim.builtin.which_key.mappings["s"] = {
  name = "split buffer",
  s = { "<cmd>split<CR>", "horizonal split" },
  v = { "<cmd>vsplit<CR>", "vertical split" }
}

lvim.builtin.which_key.mappings["a"] = {
  "<cmd>AerialToggle!<CR>", "aerial"
}
