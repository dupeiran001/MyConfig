-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

local function scandir(directory)
  local i, t, popen = 0, {}, io.popen
  local pfile = popen('ls -a "' .. directory .. '"')
  if pfile == nil then
    error("error config dir", 1)
  end
  for filename in pfile:lines() do
    if not (filename == "." or filename == "..") then
      i = i + 1
      t[i] = filename
    end
  end
  pfile:close()
  return t
end

for _, i in pairs(scandir("/Users/dupeiran/.config/lvim/lua/dpr")) do
  local i = string.gsub(i, ".lua", "")
  reload('dpr/' .. i .. '')
end
