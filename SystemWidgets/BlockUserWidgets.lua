
if addon.InGetInfo then
	return {
		name      = "UserWidgetBlocker";
		desc      = "";
		author    = "jK";
		date      = "2011";
		license   = "GNU GPL, v2 or later";

		layer     = math.huge;
		hidden    = true; -- don't show in the widget selector
		api       = true; -- load before all others?
		before    = {"all"}; -- make it loaded before ALL other widgets (-> it must be the first widget that gets loaded!)

		enabled   = true; -- loaded by default?
	}
end


function addon.Initialize()

end

function addon.BlockAddon(name, knownInfo)
	--Spring.Echo("Block?", name, knownInfo.fromZip)
	if not knownInfo.fromZip and knownInfo.name ~= "WidgetSelector" then
		--return true --// block
	end
end
