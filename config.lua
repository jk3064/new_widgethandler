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
WIDGET_DIRS     = {
	LUAUI_DIRNAME .. 'Widgets/';
	LUAUI_DIRNAME .. 'SystemWidgets/';
}


--// cache the results of time intensive funcs
include("Utilities/cache.lua", handler.EG)


--// how to handle local widgets
local localWidgetsFirst = true
local localWidgets = true
do
	handler:LoadConfigData()
	if handler.configData["Local Widgets Config"] then
		localWidgetsFirst = handler.configData["Local Widgets Config"].localWidgetsFirst
		localWidgets      = handler.configData["Local Widgets Config"].localWidgets
	end
end
handler.autoUserWidgets = (Spring.GetConfigInt('LuaAutoEnableUserWidgets', 1) ~= 0)


--// reset widget state & data on version changes
do
	local ORDER_VERSION = 3
	local DATA_VERSION  = 2

	--FIXME do this on a per widget level!!!
	handler:LoadOrderList()
	if (handler.orderList.version or ORDER_VERSION) < ORDER_VERSION then 
		handler.orderList = {}
		handler.orderList.version = ORDER_VERSION
		table.save(handler.orderList, ORDER_FILENAME, '-- Widget Order List  (0 disables a widget)')
	end

	handler:LoadConfigData()
	if (handler.configData.version or DATA_VERSION) < DATA_VERSION then
		handler.configData = {}
		handler.configData.version = DATA_VERSION
		table.save(handler.configData, CONFIG_FILENAME, '-- Widget Custom Data')
	end
end


--// VFS Mode
VFSMODE = nil
VFSMODE = localWidgetsFirst and VFS.RAW_FIRST
VFSMODE = VFSMODE or localWidgets and VFS.ZIP_FIRST
VFSMODE = VFSMODE or VFS.ZIP


--// 0: disabled
--// 1: enabled, but can be overriden by widget.GetInfo().unsafe
--// 2: always enabled
SAFEWRAP = 1
SAFEDRAW = false  --// requires SAFEWRAP to work


handler.verbose = false



--// ZK related
handler.isStable = Game.modVersion:find("stable",1,true)
function handler:IsStable()
	return self.isStable
end

local orig_NewWidget = handler.NewWidget
function handler:NewWidget()
	local env = orig_NewWidget(self)
	local h   = env.widgetHandler
	h.isStable = self.IsStable
	h.IsStable = self.IsStable
	return env
end

local orig_LoadWidgetInfo = handler.LoadWidgetInfo
function handler:LoadWidgetInfo(...)
	local wi = orig_LoadWidgetInfo(self, ...)

	if (wi) then
		--// exprimental widget
		--// change name for separate settings and disable by default
		if wi.experimental and self.isStable then
			wi.name = wi.name .. " (experimental)"
			wi.enabled = false
		end
	end

	return wi
end