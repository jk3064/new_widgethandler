--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  file:    tweakmode.lua
--  brief:   Adds a TweakMode (Ctrl+F11), so you can move/resize widgets around.
--  author:  jK (based heavily on code by Dave Rodgers)
--
--  Copyright (C) 2007,2008,2009,2010,2011.
--  Licensed under the terms of the GNU GPL, v2 or later.
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
  return {
    name      = "TweakMode",
    desc      = "Ctrl+F11 TweakMode Widget",
    author    = "jK",
    date      = "2011",
    license   = "GNU GPL, v2 or later",
    layer     = math.huge,
    hidden    = true, -- don't show in the widget selector
    handler   = true, -- needs the real widgetHandler
    enabled   = true, -- loaded by default?
    api       = true, -- load before all others?
    before    = {"all"}, -- make it loaded before ALL other widgets (-> it must be the first widget that gets loaded!)
  }
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--

local handler
local SafeCallWidget
local enteredTimer = Spring.GetTimer()

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--

function widget:Initialize()
  handler = widgetHandler
  SafeCallWidget = handler.SafeCallWidget

  handler.tweakMode = false

  function handler:InTweakMode()
    return self.tweakMode
  end

  local orig_NewWidget = handler.NewWidget
  function handler:NewWidget()
    local env = orig_NewWidget(self)
    local h   = env[handler.name]
    h.InTweakMode = handler.InTweakMode
    return env
  end

  local orig_ValidateWidget = handler.ValidateWidget
  function handler:ValidateWidget(widget)
    local err = orig_ValidateWidget(self, widget)
    if (err) then
      return err
    end
    if (widget.TweakGetTooltip and not widget.TweakIsAbove) then
      return "Widget has TweakGetTooltip() but not TweakIsAbove()"
    end
  end

  handler:AddKnownCallIn("TweakMousePress", true, false)
  handler:AddKnownCallIn("TweakMouseWheel", true, false)
  handler:AddKnownCallIn("TweakIsAbove", true, false)
  handler:AddKnownCallIn("TweakGetTooltip", true, false)
  handler:AddKnownCallIn("TweakKeyPress", true, false)
  handler:AddKnownCallIn("TweakKeyRelease", true, false)
  handler:AddKnownCallIn("TweakMouseMove", true, false)
  handler:AddKnownCallIn("TweakMouseRelease", true, false)
  handler:AddKnownCallIn("TweakDrawScreen", true, false)

  Spring.SendCommands(
    "unbindkeyset  Ctrl+f11",
    "bind C+f11  luaui tweakgui",
    "echo LuaUI: bound CTRL+F11 to tweak mode"
  )
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--  Some CallIns need custom handlers

function widget:TextCommand(command)
  if (command == 'tweakgui') then
    handler.tweakMode = not handler.tweakMode
    if handler.tweakMode then
      Spring.Echo("LuaUI: Entered TweakMode")
      enteredTimer = Spring.GetTimer()
      BindTweakFuncs()
    else
      Spring.Echo("LuaUI: Quit TweakMode")
      UnbindTweakFuncs()
    end
    return true
  end

  return false
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Draw Screen CallIn

local function DrawScreenRect()
  local inTweakModeSecs = Spring.DiffTimers(Spring.GetTimer(),enteredTimer)
  local scale = (math.tanh(inTweakModeSecs*10 - 2) + 1)/2
  local alpha = 0.6 * scale
  local dscale = 1

  local s = 0.4
  for y=-1,1-s,s do
    for x=-1,1,s do
        dscale = ((x)^2 + (y)^2)*0.4 + 0.6
        gl.Color(0, 0, 0, alpha * dscale)
        gl.Vertex(x, y, 0)

        dscale = ((x)^2 + (y+s)^2)*0.4 + 0.6
        gl.Color(0, 0, 0, alpha * dscale)
        gl.Vertex(x, y+s, 0)
    end
    --// degenerated triangle
    gl.Vertex(1, y+s, 0)
    gl.Vertex(-1, y+s, 0)
  end
end


local function TweakDrawScreen()
--[[
  local inTweakModeSecs = Spring.DiffTimers(Spring.GetTimer(),enteredTimer)
  local scale = (math.tanh(inTweakModeSecs*10 - 2) + 1)/2
  local alpha = 0.7 * scale
  gl.Color(0, 0, 0, alpha)
  local sx, sy, px, py = Spring.GetViewGeometry()
  gl.Rect(px, py, px+sx, py+sy)
--]]

  local sx, sy, px, py = Spring.GetViewGeometry()
  gl.PushMatrix()
    gl.Translate(px, py, 0)
    gl.Scale(sx, sy, 1)
    gl.Translate(0.5, 0.5, 0)
    gl.Scale(0.5,0.5, 1)
      gl.BeginEnd(GL.TRIANGLE_STRIP, DrawScreenRect)
    gl.PopMatrix()
  gl.Color(1, 1, 1)

  for _,w in handler.widgets:rev_iter() do
    SafeCallWidget(w, "DrawScreen__")
    SafeCallWidget(w, "TweakDrawScreen__")
  end
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--  Keyboard call-ins

local function TweakKeyPress(key, mods, isRepeat, label, unicode)
  local mo = handler.mouseOwner
  if (mo and mo.TweakKeyPress__) then
    SafeCallWidget(mo, "TweakKeyPress__", key, mods, isRepeat, label, unicode)
  elseif (key == KEYSYMS.ESCAPE) or (label == "Ctrl+f11") then
    if (handler.tweakMode) then
      --// Quit TweakMode
      Spring.SendCommands("luaui tweakgui")
    end
  end
  return true
end


local function TweakKeyRelease(key, mods, label, unicode)
  local mo = handler.mouseOwner
  if (mo) then
    SafeCallWidget(mo, "TweakKeyRelease__", key, mods, label, unicode)
  end
  return true
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--  Mouse call-ins

local TweakWidgetAt
do
  local lastDrawFrame = 0
  local lastx,lasty = 0,0
  local lastWidget

  local spGetDrawFrame = Spring.GetDrawFrame

  --// local helper
  TweakWidgetAt = function(self, x, y)
    local drawframe = spGetDrawFrame()
    if (lastDrawFrame == drawframe)and(lastx == x)and(lasty == y) then
      return lastWidget
    end

    lastDrawFrame = drawframe
    lastx = x
    lasty = y

    for it,f in self.callInLists.TweakIsAbove:iter() do
      if f(x, y) then
        lastWidget = it.owner
        return lastWidget
      end
    end

    lastWidget = nil
    return nil
  end
end


local function TweakMousePress(x, y, button)
  local mo = handler.mouseOwner
  if (mo and mo.TweakMousePress__) then
    SafeCallWidget(mo, "TweakMousePress__", x, y, button)
    return true  --// already have an active press
  end

  for it,f in handler.callInLists.TweakMousePress:iter() do
    if f(x, y, button) then
      handler.mouseOwner = it.owner
      return true
    end
  end
  return true
end


local function TweakMouseMove(x, y, dx, dy, button)
  --FIXME sends this event to all widgets (perhaps via a new callin PassiveMouseMove?)

  local mo = handler.mouseOwner
  if (mo) then
    SafeCallWidget(mo, "TweakMouseMove__", x, y, dx, dy, button) --no return?????
  end
  return true
end


local function TweakMouseRelease(x, y, button)
  local mo = handler.mouseOwner
  local mx, my, lmb, mmb, rmb = Spring.GetMouseState()
  if (not (lmb or mmb or rmb)) then
    handler.mouseOwner = nil
  end

  if (not mo) then
    return -1
  end

  if (mo.TweakMouseRelease) then
    SafeCallWidget(mo, "TweakMouseRelease__", x, y, button) --no return?????
  end

  return -1
end


local function TweakMouseWheel(up, value)
  for _,f in handler.callInLists.TweakMouseWheel:iter() do
    if (f(up, value)) then
      return true
    end
  end
  return true
end


local function TweakIsAbove(x, y)
  return true
end


local function TweakGetTooltip(x, y)
  for it,f in handler.callInLists.TweakGetTooltip:iter() do
    if (SafeCallWidget(it.owner, "TweakIsAbove__", x, y)) then
      local tip = f(x, y)
      if ((type(tip) == 'string') and (#tip > 0)) then
        return tip
      end
    end
  end
  return "Tweak Mode  -- hit ESCAPE to cancel"
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--

local tweakCallIns = {
  MousePress   = TweakMousePress,
  MouseMove    = TweakMouseMove,
  MouseRelease = TweakMouseRelease,
  MouseWheel   = TweakMouseWheel,

  KeyPress     = TweakKeyPress,
  KeyRelease   = TweakKeyRelease,

  IsAbove      = TweakIsAbove,
  GetTooltip   = TweakGetTooltip,

  DrawScreen   = TweakDrawScreen,
}

local origs = {}

function BindTweakFuncs()
  origs.WidgetAt = handler.WidgetAt
  handler.WidgetAt = TweakWidgetAt

  for ciName,ciFunc in pairs(tweakCallIns) do
    _G[ciName] = ciFunc
    Script.UpdateCallIn(ciName)
  end
end


function UnbindTweakFuncs()
  handler.WidgetAt = origs.WidgetAt

  for ciName in pairs(tweakCallIns) do
    _G[ciName] = nil
  end
  handler:UpdateCallIns()
end
