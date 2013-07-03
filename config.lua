--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  file:    config.lua
--  brief:   configfile for handler.lua
--  author:  jK
--
--  Copyright (C) 2011.
--  Licensed under the terms of the GNU GPL, v2 or later.
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--// Config & Widget Locations
ORDER_FILENAME  = LUAUI_DIRNAME .. 'Config/' .. Game.modShortName .. '_order.lua'
CONFIG_FILENAME = LUAUI_DIRNAME .. 'Config/' .. Game.modShortName .. '_data.lua'
KNOWN_FILENAME  = LUAUI_DIRNAME .. 'Config/' .. Game.modShortName .. '_known.lua'
ADDON_DIRS     = {
	LUAUI_DIRNAME .. 'Addons/';
	LUAUI_DIRNAME .. 'Widgets/';
	LUAUI_DIRNAME .. 'SystemWidgets/';
}


--// 0: disabled
--// 1: enabled, but can be overriden by widget.GetInfo().unsafe
--// 2: always enabled
SAFEWRAP = 1
SAFEDRAW = false  --// requires SAFEWRAP to work

--//
VFSMODE = VFS.RAW_FIRST

--// when false, the handler will `compress` some output (e.g. list of started widgets)
handler.verbose = false or true


--// ZK related
--// cache the results of time intensive funcs
include("Utilities/cache.lua", handler.EG)

handler:Load(LUAUI_DIRNAME .. "SystemWidgets/BlockUserWidgets.lua" --[[, VFS.ZIP]])
