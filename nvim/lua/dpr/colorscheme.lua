
local colorscheme = "nord"

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
  vim.notify("colorscheme " .. colorscheme .. " not found!")
  return
end


local neocomposer_status_ok,neocomposer = pcall(require, "NeoComposer")
if not neocomposer_status_ok then
  print "neocomposer_ui is not ok"
  return
end
neocomposer.setup()

