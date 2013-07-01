--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  file:    utils.lua
--  brief:   utility routines
--  author:  Dave Rodgers, jK
--
--  Copyright (C) 2007-2011.
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

UTILS_DIRNAME = LUAUI_DIRNAME .. 'Utilities/'

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
-- Utilities

local loaded_utils = {}

function require(filename, _level)
	--// check if it is in the cache
	local utilEnv = loaded_utils[filename]

	--// not in cache -> load it
	if not utilEnv then
		local filepath = UTILS_DIRNAME .. filename
		utilEnv = {}
		setmetatable(utilEnv, {__index = EG})
		local status, err = pcall(VFS.Include, filepath, utilEnv, VFSMODE or VFS.DEF_MODE)
		if status then
			loaded_utils[filename] = utilEnv
		else
			error(("Failed to load util \"%s\": %s."):format(filename, err), 2)
		end
	end


	--// get caller's enviroment
	_level = _level or 2
	local success, _G
	for i=_level,_level+10 do
		success, _G = pcall(getfenv, i+1) --// +1 cause of pcall!
		if success then
			break
		end
	end
	if not success then
		error(_G)
		return
	end

	--// copy to caller's enviroment
	--FIXME use recursive copy?
	for i,v in pairs(utilEnv) do
		_G[i] = v
	end
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Include

function include(filename, envTable, VFSMODE)
	if filename == "colors.h.lua" then
		return require("colors.lua") --// tail call so we don't need to bother with stacklevels
	end
	if filename == "keysym.h.lua" then
		Spring.Log(LUA_NAME, "warning", "Headers files aren't supported anymore use \"require\" instead!")
		return require("keysym.lua") --// tail call so we don't need to bother with stacklevels
	end
	if filename:find(".h.", 1, true) then
		--// give error on old LuaUI syntax (<=0.82)
		error("Headers files aren't supported anymore use \"require\" instead!", 2)
	end

	return VFS.Include(LUAUI_DIRNAME .. filename, envTable, VFSMODE or VFS.DEF_MODE)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
