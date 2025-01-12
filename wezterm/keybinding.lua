local M = {}

local wezterm = require("wezterm")
local act = wezterm.action

M.keys = {
  {
    key = "x",
    mods = "ALT",
    action = act.CloseCurrentTab({ confirm = false }),
  },
  {
    key = "=",
    mods = "ALT",
    action = act.SpawnTab("DefaultDomain"),
  },
  {
    key = "1",
    mods = "ALT",
    action = act.ActivateTab(0),
  },
  {
    key = "1",
    mods = "ALT",
    action = act.ActivateTab(0),
  }, {
  key = "2",
  mods = "ALT",
  action = act.ActivateTab(1),
}, {
  key = "3",
  mods = "ALT",
  action = act.ActivateTab(2),
}, {
  key = "4",
  mods = "ALT",
  action = act.ActivateTab(3),
}, {
  key = "5",
  mods = "ALT",
  action = act.ActivateTab(4),
}, {
  key = "6",
  mods = "ALT",
  action = act.ActivateTab(5),
}, {
  key = "7",
  mods = "ALT",
  action = act.ActivateTab(6),
}, {
  key = "8",
  mods = "ALT",
  action = act.ActivateTab(7),
},
  {
    key = "9",
    mods = "ALT",
    action = act.ActivateTab(8),
  }
}

M.key_tables = {

  search_mode = {
    { key = "Enter",  mods = "NONE", action = act.CopyMode("NextMatch") },
    { key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
    { key = "j",      mods = "CTRL", action = act.CopyMode("NextMatch") },
    { key = "k",      mods = "CTRL", action = act.CopyMode("PriorMatch") },
    { key = "n",      mods = "CTRL", action = act.CopyMode("NextMatch") },
    { key = "p",      mods = "CTRL", action = act.CopyMode("PriorMatch") },
    { key = "r",      mods = "CTRL", action = act.CopyMode("CycleMatchType") },
    { key = "u",      mods = "CTRL", action = act.CopyMode("ClearPattern") },
    {
      key = "PageUp",
      mods = "NONE",
      action = act.CopyMode("PriorMatchPage"),
    },
    {
      key = "PageDown",
      mods = "NONE",
      action = act.CopyMode("NextMatchPage"),
    },
    { key = "UpArrow",    mods = "NONE", action = act.CopyMode("PriorMatch") },
    { key = "DownArrow",  mods = "NONE", action = act.CopyMode("NextMatch") },
    { key = "LeftArrow",  mods = "NONE", action = act.CopyMode("PriorMatchPage") },
    { key = "RightArrow", mods = "NONE", action = act.CopyMode("NextMatchPage") },
  },
}

return M
