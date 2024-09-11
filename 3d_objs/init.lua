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

minetest.register_node(modname .. ":bird2", {
	description = "Bird 2",
	drawtype = "mesh",
	mesh = "bird2.obj",
	tiles = {
		{ name = "birds_baseColor.png" }
	},

})

minetest.register_node(modname .. ":bugatti", {
	description = "Bugatti",
	drawtype = "mesh",
	mesh = "bugatti.obj",
	tiles = {
		-- { name = "birds_baseColor.png" }
	},
	groups = {
		armor = 1,
		non_combat_armor = 1,
		armor_head = 1,
		non_combat_armor_head = 1,
		armor_torso = 1,
		non_combat_armor_torso = 1,
		armor_legs = 1,
		non_combat_armor_legs = 1,
		armor_feet = 1,
		non_combat_armor_feet = 1,
	},
	on_secondary_use = mcl_armor.equip_on_use,
})
minetest.register_node(modname .. ":bugatti2015", {
	description = "Bugatti 2015",
	drawtype = "mesh",
	mesh = "bugatti2015.obj",
	tiles = {
		{ name = "B_logo_baseColor.png" },
		{ name = "b_logo_f_baseColor.png" },
		{ name = "caliper_logo_baseColor.png" },
		{ name = "camera_baseColor.png" },
		{ name = "dash_number_baseColor.png" },
		{ name = "decal_baseColor.png" },
		{ name = "disc_f_baseColor.png" },
		{ name = "engine_grid_baseColor.png" },
		{ name = "fengxian1_baseColor.png" },
		{ name = "luosi_baseColor.png" },
	},
	groups = {
		armor = 1,
		non_combat_armor = 1,
		armor_head = 1,
		non_combat_armor_head = 1,
		-- armor_torso = 1,
		-- non_combat_armor_torso = 1,
		-- armor_legs = 1,
		-- non_combat_armor_legs = 1,
		-- armor_feet = 1,
		-- non_combat_armor_feet = 1,
	},
	_mcl_armor_element = "head",
	on_secondary_use = mcl_armor.equip_on_use,
})

minetest.register_node(modname .. ":v1plush", {
	description = "V1 Plush",
	drawtype = "mesh",
	mesh = "V1Plush.obj",
	tiles = {
		{ name = "T_V1Plush.png" }
	},

})


local rawitemstring = [[
3d_objs/textures/skeld_textures/Caja_t01_baseColor.jpeg 3d_objs/textures/skeld_textures/Caja_t02_baseColor.jpeg 3d_objs/textures/skeld_textures/Caja_t03_baseColor.jpeg 3d_objs/textures/skeld_textures/Caja_tex_baseColor.jpeg 3d_objs/textures/skeld_textures/Formica_baseColor.jpeg 3d_objs/textures/skeld_textures/Groundco_baseColor.jpeg 3d_objs/textures/skeld_textures/medicina_baseColor 3d_objs/textures/skeld_textures/medicina_emissive 3d_objs/textures/skeld_textures/monito01_baseColor 3d_objs/textures/skeld_textures/monito02_baseColor 3d_objs/textures/skeld_textures/monitor_baseColor 3d_objs/textures/skeld_textures/motores_baseColor.jpeg 3d_objs/textures/skeld_textures/pared_ad_baseColor.jpeg 3d_objs/textures/skeld_textures/pared_ad_metallicRoughness 3d_objs/textures/skeld_textures/pared_al_baseColor.jpeg 3d_objs/textures/skeld_textures/pared_al_metallicRoughness 3d_objs/textures/skeld_textures/pared_ca_baseColor.jpeg 3d_objs/textures/skeld_textures/pared_es_baseColor.jpeg 3d_objs/textures/skeld_textures/paredes_baseColor.jpeg 3d_objs/textures/skeld_textures/piso_alm_baseColor.jpeg 3d_objs/textures/skeld_textures/piso_caf_baseColor 3d_objs/textures/skeld_textures/piso_cam_baseColor.jpeg 3d_objs/textures/skeld_textures/piso_com_baseColor.jpeg 3d_objs/textures/skeld_textures/piso_ele_baseColor.jpeg 3d_objs/textures/skeld_textures/PISO_M01_baseColor.jpeg 3d_objs/textures/skeld_textures/PISO_M02_baseColor.jpeg 3d_objs/textures/skeld_textures/PISO_MED_baseColor.jpeg 3d_objs/textures/skeld_textures/piso_p01_baseColor.jpeg 3d_objs/textures/skeld_textures/piso_pas_baseColor.jpeg 3d_objs/textures/skeld_textures/piso_t01_baseColor.jpeg 3d_objs/textures/skeld_textures/piso_t02_baseColor.jpeg 3d_objs/textures/skeld_textures/piso_t03_baseColor.jpeg 3d_objs/textures/skeld_textures/piso_t04_baseColor.jpeg 3d_objs/textures/skeld_textures/piso_tex_baseColor.jpeg 3d_objs/textures/skeld_textures/reacto01_baseColor.jpeg 3d_objs/textures/skeld_textures/reactor_baseColor.jpeg 3d_objs/textures/skeld_textures/separado_baseColor.jpeg 3d_objs/textures/skeld_textures/test_med_baseColor 3d_objs/textures/skeld_textures/text_c01_baseColor.jpeg 3d_objs/textures/skeld_textures/text_com_baseColor.jpeg 3d_objs/textures/skeld_textures/TEXT_NAV_baseColor.jpeg 3d_objs/textures/skeld_textures/textu_01_baseColor.jpeg 3d_objs/textures/skeld_textures/textu_pi_baseColor.jpeg 3d_objs/textures/skeld_textures/TEXTUR01_baseColor.jpeg 3d_objs/textures/skeld_textures/TEXTURA_baseColor.jpeg 3d_objs/textures/skeld_textures/textura_baseColor 3d_objs/textures/skeld_textures/Water_Da_baseColor.jpeg
]]
local skeld_textures = string.split(
	string.gsub(string.gsub(rawitemstring, "3d_objs/textures/", ""), ".jpeg", ""),
" ")
local named_skeld_textures = {}
for i, v in ipairs(skeld_textures) do
	named_skeld_textures[i] = { name = v }
end
minetest.register_node(modname .. ":skeld", {
	description = "Skeld",
	drawtype = "mesh",
	mesh = "skeld.obj",
	tiles = named_skeld_textures,

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


minetest.register_node(modname .. ":black_cat", {
	description = "Black Cat",
	drawtype = "mesh",
	mesh = "black_cat.obj",
	tiles = {
		{ name = "Cat_diffuse.png" },
		{ name = "Cat_bump.png" },
	},
})


-- link image signs