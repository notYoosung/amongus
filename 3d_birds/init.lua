local modpath = minetest.get_modpath(minetest.get_current_modname())
local modname = minetest.get_current_modname()

local S = minetest.get_translator(minetest.get_current_modname())
local F = minetest.formspec_escape
local C = minetest.colorize




minetest.register_node(modname .. ":bird1", {
	description = "Bird 1",
	drawtype = "mesh",
	mesh = "bird1.obj",
	tiles = {
		{name = "birds_baseColor.png"}
	},
	
})