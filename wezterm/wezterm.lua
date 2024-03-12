require("helpers")

local config = {}
local wezterm = require("wezterm")

local tabs_config = require("tabs")
table_merge(config, tabs_config)

local startup_config = require("startup")
table_merge(config, startup_config)

local fonts_config = require("fonts")
table_merge(config, fonts_config)

config.color_scheme = "nord"
return config
