local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)


minetest.register_node(modname .. ":castle", {
	description = "Castle",
	tiles = {{name = "castle_640.png", align_style = "world", scale = 16}},
	inventory_image = "castle_640.png",
	groups = {oddly_breakable_by_hand = 1},
	use_texture_alpha = "clip",
})