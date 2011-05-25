--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  file:    utils.lua
--  brief:   utility routines
--  author:  Dave Rodgers
--
--  Copyright (C) 2007.
--  Licensed under the terms of the GNU GPL, v2 or later.
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

if (UtilsGuard) then
	return
end
UtilsGuard = true

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--// needed below
local EG = getfenv()

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--  returns:  basename, dirname
--

function Basename(fullpath)
	local _,_,base = fullpath:find("([^\\/:]*)$")
	local _,_,path = fullpath:find("(.*[\\/:])[^\\/:]*$")
	if (path == nil) then path = "" end
	return base, path
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Modules

local loaded_modules = {}

function require(filename, _level)
	--// check if it is in the cache
	local moduleEnv = loaded_modules[filename]

	--// not in cache -> load it
	if not moduleEnv then
		local filepath = LUAUI_DIRNAME .. 'Modules/' .. filename
		moduleEnv = {}
		setmetatable(moduleEnv, {__index = EG})
		local status, err = pcall(VFS.Include, filepath, moduleEnv, VFSMODE or VFS.DEF_MODE)
		if status then
			loaded_modules[filename] = moduleEnv
		else
			error(("Failed to load module \"%s\": %s."):format(filename, err), 2)
		end
	end

	--// copy to caller's enviroment
	local _G = getfenv(_level or 2)
	for i,v in pairs(moduleEnv) do
		_G[i] = v
	end
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Include

function include(filename, envTable, VFSMODE)
	if filename == "colors.h.lua" then
		return require("colors.lua", 3)
	end
	if filename == "keysym.h.lua" then
		Spring.Echo("Headers files aren't supported anymore use \"require\" instead!", 2)
		return require("keysym.lua", 3)
	end
	if filename:find(".h.", 1, true) then
		--// give error on old LuaUI syntax (<=0.82)
		error("Headers files aren't supported anymore use \"require\" instead!", 2)
	end

	return VFS.Include(LUAUI_DIRNAME .. filename, envTable, VFSMODE or VFS.DEF_MODE)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
