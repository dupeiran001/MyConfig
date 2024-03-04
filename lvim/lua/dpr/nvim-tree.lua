local nvimtree = lvim.builtin.nvimtree

local function my_on_attach(bufnr)
  local api = require "nvim-tree.api"

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- default mappings
  api.config.mappings.default_on_attach(bufnr)

  -- custom mappings
  vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts('close node preview'))
  vim.keymap.set('n', 'l', api.node.open.edit, opts('open node preview'))
  vim.keymap.set('n', '<Tab>', "<C-w>w", opts('change focus'))
end
nvimtree.setup.on_attach = my_on_attach

nvimtree.setup.hijack_cursor = true

nvimtree.setup.disable_netrw = true

-- auto chdir to project root
nvimtree.setup.sync_root_with_cwd = false
nvimtree.setup.respect_buf_cwd = false
nvimtree.setup.prefer_startup_root = false
nvimtree.setup.update_focused_file.enable = false


-- highlight render
nvimtree.setup.renderer.indent_markers.enable = true
nvimtree.setup.renderer.highlight_git = true
nvimtree.setup.renderer.highlight_diagnostics = true
nvimtree.setup.renderer.icons.show.git = false
nvimtree.setup.diagnostics.enable = true
nvimtree.setup.diagnostics.show_on_dirs = true
nvimtree.setup.diagnostics.show_on_open_dirs = false

-- modified highlight
nvimtree.setup.modified.enable = true
nvimtree.setup.modified.show_on_dirs = true
nvimtree.setup.modified.show_on_open_dirs = true

-- include ignored files
nvimtree.setup.filters.git_ignored = true
nvimtree.setup.filters.git_clean = true
nvimtree.setup.filters.no_buffer = true
nvimtree.setup.filters.dotfiles = true
