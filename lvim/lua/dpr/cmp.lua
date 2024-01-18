lvim.builtin.cmp.experimental.ghost_text = true
lvim.builtin.cmp.view.entry = true

lvim.builtin.cmp.sources = {
  {
    name = "nvim_lsp",
    entry_filter = function(entry, ctx)
      local kind = require("cmp.types").lsp.CompletionItemKind[entry:get_kind()]
      if kind == "Snippet" then
        return false
      end
      if kind == "Text" then
        return false
      end
      if kind == "Keyword" then
        return false
      end
      return true
    end,
  },
  -- { name = "cmp_tabnine", max_item_count = 3 },
  { name = "path",  max_item_count = 5 },
  -- { name = "luasnip", max_item_count = 3 },
  -- { name = "buffer",  max_item_count = 5, keyword_length = 5 },
  -- { name = "nvim_lua" },
  -- { name = "calc" },
  -- { name = "emoji" },
  -- { name = "treesitter" },
  { name = "crates" },
}

lvim.builtin.cmp.formatting.fields = { "kind", "abbr", "menu" }

lvim.builtin.cmp.formatting.format = function(entry, vim_item)
  vim_item = lvim.builtin.cmp.formatting.format(entry, vim_item)
  vim_item.menu = entry:get_completion_item().detail
  return vim_item
end
