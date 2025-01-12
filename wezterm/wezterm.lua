require("helpers")

local config = {}

local tabs_config = require("tabs")
TableMerge(config, tabs_config)

-- something failed to configure, lets use my own tabs
-- require("tabline")

local startup_config = require("startup")
TableMerge(config, startup_config)

local fonts_config = require("fonts")
TableMerge(config, fonts_config)

local scrollback_config = require("scrollback")
TableMerge(config, scrollback_config)

local keybindings_config = require("keybinding")
TableMerge(config, keybindings_config)

config.color_scheme = "OneNord"
return config
