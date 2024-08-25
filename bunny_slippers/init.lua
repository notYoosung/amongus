local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

local skins_list = {
	-- "white",
	"2"
}

minetest.register_on_mods_loaded(function()
	local indx = #mcl_skins.simple_skins
	for i, v in pairs(skins_list) do
		mcl_skins.register_simple_skin({
			index = indx,
			texture = "bunny_slippers_" .. v .. ".png"
		})
		indx = indx + 1
	end
end)




--crawl, trident