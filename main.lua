--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  file:    main.lua
--  brief:   the entry point from LuaUI
--  author:  jK
--
--  Copyright (C) 2011.
--  Licensed under the terms of the GNU GPL, v2 or later.
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

LUA_NAME      = Script.GetName()
LUAUI_DIRNAME = Script.GetName() .. "/"
LUAUI_VERSION = Script.GetName() .. " v1.0"

VFS.DEF_MODE = VFS.RAW_FIRST
if (VFS.FileExists("gamedata/lockluaui.txt")) then
	VFS.DEF_MODE = VFS.ZIP_FIRST
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
-- Load
--

VFS.Include(LUAUI_DIRNAME .. 'utils.lua', nil, VFS.DEF_MODE)

--// Lua-based fonthandler (deprecated)
require "fonts.lua"

--// the addon handler
include "handler.lua"

--// print Lua & LuaUI version
Spring.Echo(LUAUI_VERSION .. " (" .. _VERSION .. ")")

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
--  Update()
--

--FIXME move to handler or a widget?
function Update()
	fontHandler.Update()

	handler:Update()
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
