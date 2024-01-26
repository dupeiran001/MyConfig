lvim.builtin.project.show_hidden = true

local idx, new_pattern = 1, {}
for line in lvim.builtin.project.patterns do
  if not line == "pom.xml" then
    new_pattern[idx] = line
  end
  idx = idx + 1
end

lvim.builtin.project.patterns = { ".git" }
