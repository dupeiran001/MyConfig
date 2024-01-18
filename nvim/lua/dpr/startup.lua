

local status_ok, startup = pcall(require, "startup")
if not status_ok then
  print "startup is not ok"
  return
end
startup.setup()
