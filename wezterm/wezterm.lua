require("helpers")

local config = {}
local wezterm = require("wezterm")

local tabs_config = require("tabs")
TableMerge(config, tabs_config)

local startup_config = require("startup")
TableMerge(config, startup_config)

local fonts_config = require("fonts")
TableMerge(config, fonts_config)

local scrollback_config = require("scrollback")
TableMerge(config, scrollback_config)

config.color_scheme = "nord"
return config
