local telescope = lvim.builtin.telescope
local actions = require("telescope.actions")

for idx, par in pairs(telescope.defaults.vimgrep_arguments) do
  if par == '--smart-case' then
    table.remove(telescope.defaults.vimgrep_arguments, idx)
  end
end

telescope.defaults.mappings.i["<C-j>"] = actions.move_selection_next
telescope.defaults.mappings.i["<C-k>"] = actions.move_selection_previous
telescope.defaults.mappings.i["<ESC>"] = actions.close

telescope.theme = "center"
