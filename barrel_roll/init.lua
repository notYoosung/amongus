local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

--playerphysics

local player_look_dirs = {}

minetest.register_on_joinplayer(function(ObjectRef, last_login)
	player_look_dirs[ObjectRef:get_player_name()] = ObjectRef:get_look_dir()
end)

minetest.register_on_leaveplayer(function(ObjectRef, timed_out)
	player_look_dirs[ObjectRef:get_player_name()] = nil
end)

mcl_player.register_globalstep(function(player, dtime)
	-- local fly_pos = player:get_pos()
	-- local fly_node = minetest.get_node({x = fly_pos.x, y = fly_pos.y - 0.1, z = fly_pos.z}).name
	-- local player_vel = player:get_velocity()
	-- if player == nil then return end
minetest.log(player)
	local elytra = mcl_player.players[player].elytra
	-- if elytra.active then
	local player_look_dir = player:get_look_dir()
	local new_dir = vector.add(player_look_dir, {x = 10, y = 0, z = 0})
	player:set_rotation(new_dir)
	player_look_dirs[player:get_player_name()] = new_dir
end)
