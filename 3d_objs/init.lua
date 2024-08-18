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



mcl_mobs.register_mob(modname .. ":freddy", {
	description = "Freddy",
	type = "monster",
	spawn_class = "hostile",
	pathfinding = 1,
	hp_min = 100,
	hp_max = 100,
	xp_min = 100,
	xp_max = 100,
	collisionbox = { -0.3 * 2, -0.01 * 2, -0.3 * 2, 0.3 * 2, 1.94 * 2, 0.3 * 2 },
	visual = "mesh",
	mesh = "Freddy.b3d",
	-- head_swivel = "head.control",
	-- bone_eye_height = 2.2,
	-- head_eye_height = 2.2,
	curiosity = 10,
	textures = {
		{
			"Freddy_UV.png",
		},
	},
	visual_size = { x = 10 * 2, y = 10 * 2, z = 10 * 2 },
	makes_footstep_sound = true,
	damage = 13,
	reach = 2,
	walk_velocity = 1.2,
	run_velocity = 1.6,
	attack_type = "dogfight",
	attack_npcs = true,
	drops = {
		{
			name = "mcl_core:emerald",
			chance = 1,
			min = 0,
			max = 1,
			looting = "common",
		},
		{
			name = "mcl_tools:axe_iron",
			chance = 100 / 8.5,
			min = 1,
			max = 1,
			looting = "rare",
		},
	},
	-- TODO: sounds
	animation = {
		stand_start = 40,
		stand_end = 59,
		stand_speed = 30,
		walk_start = 0,
		walk_end = 40,
		walk_speed = 50,
		punch_start = 90,
		punch_end = 110,
		punch_speed = 25,
		die_start = 170,
		die_end = 180,
		die_speed = 15,
		die_loop = false,
	},
	view_range = 16,
	fear_height = 4,
})

mcl_mobs.register_egg(modname .. ":freddy", "Freddy", "#959b9b", "#275e61", 0)
