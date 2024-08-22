local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)


local sounds = assert(io.open("./sounds"))


minetest.register_tool(modname .. ":horn", {
	description = "Horn",
	image = "",
	inventory_image = "",
	use_texture_alpha = "clip",
	on_secondary_use = function()

	end,
})