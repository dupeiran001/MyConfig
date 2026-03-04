local function scandir(directory)
	local i, t, popen = 0, {}, io.popen
	local pfile = popen('ls -a "' .. directory .. '"')
	if pfile == nil then
		error("error config dir: dir not exist", 1)
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

local config_root = vim.fn.stdpath("config")
package.path = config_root .. "/?.lua;" .. package.path

-- Some plugins still use the deprecated `vim.validate{...}` form. Keep their
-- behavior but route through the non-deprecated API.
local function shim_deprecated_validate_spec()
	local original_validate = vim.validate
	local type_aliases = {
		b = "boolean",
		c = "callable",
		f = "function",
		n = "number",
		s = "string",
		t = "table",
	}

	local function normalize_validator(validator)
		if type(validator) == "string" then
			return type_aliases[validator] or validator
		end
		if type(validator) == "table" then
			local normalized = {}
			for i, v in ipairs(validator) do
				normalized[i] = type_aliases[v] or v
			end
			return normalized
		end
		return validator
	end

	vim.validate = function(name, value, validator, optional, message)
		if validator ~= nil or type(name) ~= "table" then
			return original_validate(name, value, validator, optional, message)
		end

		local spec = name
		local keys = vim.tbl_keys(spec)
		table.sort(keys)

		for _, key in ipairs(keys) do
			local rule = spec[key]
			if type(rule) ~= "table" then
				error(string.format("invalid specification for argument '%s'", key), 2)
			end
			original_validate(key, rule[1], normalize_validator(rule[2]), rule[3], rule[4])
		end
	end
end

shim_deprecated_validate_spec()

-- load other configs
for _, i in ipairs(scandir(config_root .. "/lua/config")) do
	local filename = string.gsub(i, ".lua", "")
	require("config." .. filename .. "")
end

-- startup with lazy.nvim
local bootstrap_status, _ = pcall(require, "bootstrap")
if not bootstrap_status then
	error("cannot found bootstrap.lua in root directory, exiting")
end
