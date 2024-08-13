local M = {}

-- set proxy by default
-- TODO: auto check proxy status before setting proxy env
M.set_environment_variables = {
	-- ALL_PROXY = "socks5://127.0.0.1:55906",
	-- HTTP_PROXY = "socks5://127.0.0.1:55906",
	-- HTTPS_PROXY = "socks5://127.0.0.1:55906",
}

return M
