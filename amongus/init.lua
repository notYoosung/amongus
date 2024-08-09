local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)


dofile(modpath .. "/candles_3d/init.lua")
dofile(modpath .. "/creative_dispenser.lua")
dofile(modpath .. "/mlg_water_bucket.lua")

local kill_cooldown = 10
local discussion_duration = 0
local voting_duration = 60



minetest.registered_nodes["mcl_core:ice"].drawtype = "normal"
minetest.registered_nodes["mcl_core:ice"].use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false

local storage = minetest.get_mod_storage()
local backend = {}
function backend.set_string(key, value)
    storage:set_string(key, tostring(value))
end
function backend.get_string(key)
    return storage:get_string(key)
end
function backend.set_table(key, value)
    storage:set_string(key, minetest.serialize(value))
end
function backend.get_table(key)
    return minetest.deserialize(storage:get_string(key))
end


local function highlight(message)
    return minetest.colorize("#00ffff", message)
end

--ඞ

if not (minetest.get_modpath("z") or minetest.get_modpath("hidename")) then
    dofile(modpath .. "/hidename/init.lua")
end



mcl_doors:register_trapdoor(modname .. ":amongus_vent_trapdoor", {
    description = S("Vent Trapdoor"),
	_doc_items_longdesc = S("Vent trapdoors are horizontal barriers which can only be opened and closed by redstone signals, but not by hand. They occupy the upper or lower part of a block, depending on how they have been placed. When open, they can be climbed like a ladder."),
	tile_front = "amongus_vent_top.png",
	tile_side = "amongus_vent_side.png",
	wield_image = "amongus_vent_top.png",
	groups = {pickaxey=1, mesecon_effector_on=1},
	_mcl_hardness = 5,
	_mcl_blast_resistance = 5,
	sounds = mcl_sounds.node_sound_metal_defaults(),
	sound_open = "amongus_vent_open",
	sound_close = "amongus_vent_close",
    
})



--playsound box
--ping

--set other ppls hotbar

--invis climbable block

--visual cooldown

--amongus emergency meeting sign on hud

local player_original_disguise_properties = {}
local player_initial_properties = {}
local function get_entity_properties_with_defaults(properties, player_name)
	if not properties then return end
	properties.nametag = player_name
	properties.automatic_rotate = properties.automatic_rotate or 0
	properties.visual_size = properties.visual_size or {x = 1, y = 1}

	return properties
end



local amongus_players = {}


local round

round = {
    -- gamemaster = "",
    -- gamemmaster_votes = {},
    meeting_pos = vector.zero(),
    active = false,
    votes = {},
    is_voting = false,
    start = function()
        minetest.chat_send_all("Among Us minigame started!")

        local random_imposter = amongus_players[math.random(#amongus_players)]
        for k, v in pairs(amongus_players) do
            if v == random_imposter then
                v.is_imposter = true
                -- if not player_initial_properties[k] then
                    player_initial_properties[k] = get_entity_properties_with_defaults(
                        player:get_properties(), k
                    )
                -- end
                minetest.after(kill_cooldown, function()
                    v.can_kill = true
                    minetest.log(tostring(amongus_players[k].is_imposter))
                end)
            end
            hidename.hide(k)
        end

        round.active = true
    end,
    stop = function()
        minetest.chat_send_all("Among Us minigame ended!")
        for k, v in pairs(amongus_players) do
            hidename.show(k)
            amongus_players[k] = nil
        end

        round.active = false
    end,
    on_player_leave = function(player)
        local player_name = player:get_player_name()
        amongus_players[player:get_player_name()] = nil
        hidename.show(player:get_player_name())
    end,
    pre_meeting_poses = {},
    on_start_meeting = function()
        round.is_voting = true
        for k, v in pairs(amongus_players) do
            local player = minetest.get_player_by_name(k)
            round.pre_meeting_poses[k] = player:get_pos()
            player:move_to(round.meeting_pos)
            minetest.chat_send_player(k, "Meeting called! Teleporting to meeting pos!")
            if amongus_players[k].is_dead then
                minetest.chat_send_player(k, "You're dead, so please don't chat or show who's the imposter! Watch the discussion and check out how everyone responds!")
            else
                minetest.chat_send_player(k,
                    "Do " ..
                    highlight("/au vote PlayerName") ..
                    " to vote that player out!\nDo " ..
                    highlight("/au skipvote") ..
                    " to skip!\n"
                )
            end
            minetest.chat_send_player(k, "Voting begins in " .. highlight(discussion_duration) .. " seconds, and it will last for " .. highlight(voting_duration) .. " seconds! (Total " .. highlight(discussion_duration + voting_duration) .. " seconds)")
        end
    end,
    on_stop_meeting = function()
        round.is_voting = false
        for k, v in pairs(pre_meeting_poses) do
            local player = minetest.get_player_by_name(k)
            player:move_to(round.pre_meeting_poses[k])
            round.pre_meeting_poses[k] = nil
        end
    end
}
local stored_meeting_pos = backend.get_table("amongus_meeting_pos")
if stored_meeting_pos == nil then
    backend.set_table("amongus_meeting_pos", round.meeting_pos)
    minetest.log("Among Us meeting pos not set! Defaulting to (0, 0, 0). Do " .. highlight("/au setmeeingpos") .. " (requires server priv).")
else
    round.meeting_pos = stored_meeting_pos
end

minetest.register_on_joinplayer(function(player)
    minetest.chat_send_player(player:get_player_name(), "Join our Among Us minigame! Do \"/au join\" and wait for a gamemaster to start a round :D")
end)

minetest.register_on_leaveplayer(function(player)
    player_original_disguise_properties[player:get_player_name()] = nil
    player_initial_properties[player:get_player_name()] = nil
    round.on_player_leave(player)
    minetest.chat_send_all(highlight(player:get_player_name() .. " has left the Among Us minigame!"))
end)

local function is_player_joined(player_or_name)
    if minetest.is_player(player_or_name) then
        player_or_name = player_or_name:get_player_name()
    end
    for k, v in pairs(amongus_players) do
        if player_or_name == k then
            return true
        end
    end
    return false
end

local function get_player_names()
    local players = {}
    for k, v in pairs(amongus_players) do
        table.insert(players, k)
    end
    return players
end

local function get_imposter_names()
    local imposters = {}
    for k, v in pairs(amongus_players) do
        if v.is_imposter then
            table.insert(imposters, k)
        end
    end
    return imposters
end

local function get_crew_names()
    local crew = {}
    for k, v in pairs(amongus_players) do
        if not v.is_imposter then
            table.insert(crew, k)
        end
    end
    return crew
end




minetest.register_privilege("amongus_gamemaster", {
    description = "Gives controls for the Among Us minigame"
})



local auhelp = table.concat({
    highlight("The Among Us minigame command"),
    highlight("/au players") .. " - list out the joined players!",
    highlight("/au join") .. " - enter the Among Us minigame!",
    highlight("/au color") .. " - set your skin color!",
    highlight("/au outfit") .. " - set your outfit!",
    highlight("/au hat") .. " - set your hat!",
    highlight("/au visor") .. " - set your visor!",
    highlight("/au start") .. " - start the minigame!",
    highlight("/au forcestart") .. " - start the minigame, even if there aren't enough players! (requires server or amongus_gamemaster priv)",
    highlight("/au stop") .. " - stop the minigame!",
    highlight("/au meeting") .. " - call a meeting!",
    highlight("/au setmeetingpos") .. " - set the meeting pos! (requires server or amongus_gamemaster priv)",
    highlight("/au vote") .. " - vote to eject the imposter!",
}, "\n")

minetest.register_chatcommand("au", {
	params = "<cmd> (<params>)",
	description = auhelp,
	privs = { interact = true },
	func = function(name, params)
        local player = minetest.get_player_by_name(name)
		local args = params:split(" ")
		local cmd = args[1]
        if cmd == nil or cmd == "" then
            minetest.chat_send_player(name, auhelp)
            return

        elseif cmd == "players" then
            minetest.chat_send_player(name, "Current Among Us players (" .. #amongus_players .. "): " .. table.concat(get_player_names()))

        elseif cmd == "join" then
            amongus_players[name] = {
                is_imposter = false,
                is_dead = false,
                can_kill = false,
                color = "",
                skin = "",
                hat = "",
                visor = "",
                outfit = "",
            }

            minetest.chat_send_all(highlight(name) .. " joined Among Us!\nCurrent players (" .. #amongus_players .. "): " .. table.concat(get_player_names()))
            minetest.chat_send_player(name, "You joined the Among Us game! Please wait for the round to start.")

        -- elseif cmd == "votegm" then
        --     if minetest.player_exists(args[2]) then
        --         local vote = round.gamemaster_votes[name]
        --         if vote == args[2] then
        --             minetest.chat_send_player(name, "You already voted for " .. args[2])
        --         elseif round.gamemaster_votes
        --         end
        --         round.gamemaster_votes[]
        --     else
        --         minetest.chat_send_player(name, "Please enter a valid player name! Tip: type the first few letters of the target player and press TAB to autocomplete the name")
        --     end
        
        elseif cmd == "color" then
            local model_properties = {
                visual = "mesh",
                texture = "amongus_player_yellow",
            }

            local colornames = {


            }

            if args[2] == nil or args[2] == "" then

            else
                for k, v in pairs(colornames) do
                    if args[2] == v then
                        minetest.chat_send_player(name, "You color is changed to " .. k .. "!")
                        break
                    end
                end
            end

            player:set_model(model_properties)
            player_original_disguise_properties[name] = model_properties
        elseif cmd == "outfit" then
            
        elseif cmd == "hat" then
            
        elseif cmd == "visor" then
            
        elseif cmd == "forcestart" then
            if minetest.check_player_privs(name, "server") or minetest.check_player_privs(name, "amongus_gamemaster") then
                round.start()
            else
                minetest.chat_send_player(name, "You don't have the required privs! (server or amongus_gamemaster)")
            end

        elseif cmd == "start" then
            if #amongus_players >= 4 then
                round.start()
            else
                minetest.chat_send_player(name, "Not enough players have joined!\nCurrent players (" .. #amongus_players .. "): " .. table.concat(get_player_names()))
            end

        elseif cmd == "stop" then
            round.stop()

        elseif cmd == "meeting" then
            round.on_start_meeting()

        elseif cmd == "setmeetingpos" then
            if minetest.check_player_privs(name, "server") or minetest.check_player_privs(name, "amongus_gamemaster") then
                round.meeting_pos = vector.round(player:get_pos())
                backend.set_table("amongus_meeting_pos", round.meeting_pos)
                minetest.chat_send_player(name, "New Among Us meeting position set!")
            else
                minetest.chat_send_player(name, "You don't have the server priv!")
            end

        elseif cmd == "vote" then
            if amongus_players[name].is_dead then
                minetest.chat_send_player(name, "You can't vote, you were killed!")
                return
            elseif round.votes[name] ~= nil then
                minetest.chat_send_player(name, "You can't vote, you already voted!")
                return
            elseif not round.is_voting then
                minetest.chat_send_player(name, "You can't vote, the voting hasn't started yet!")
                return
            elseif args[2] == "" or args[2] == nil then
                minetest.chat_send_player(name, "Please type a player's name to vote! Example: " .. highlight("/au vote PlayerName"))
                return
            elseif not minetest.player_exists(args[2]) then
                minetest.chat_send_player(name, highlight(args[2]) .. " isn't a valid player name!")
                return
            elseif not is_player_joined(args[2]) then
                minetest.chat_send_player(name, highlight(args[2]) .. " isn't currently joined in the Among Us minigame!")
            end

            minetest.chat_send_player(name, "You voted to eject " .. args[2] .. "!")
            round.votes[name] = args[2]

        else
            minetest.chat_send_player(name, "\"" .. cmd .. "\" isn't a valid subcommand!")
        end
    end
})


minetest.register_tool(modname .. ":amongus_tool", {
	description = "Amongus Tool",
	inventory_image = "amongus_button_emergency_meeting.png",
	wield_scale = wield_scale,
	-- groups = { tool=1, dig_speed_class=7, enchantability=100 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.1,
		max_drop_level=0,
		-- damage_groups = {fleshy=5},
		punch_attack_uses = -1,
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = mcl_tools.tool_place_funcs.pick,
	on_use = function(itemstack, user, pointed_thing)
        mcl_tools.entity = pointed_thing.ref
        local playerref = mcl_tools.entity
        if pointed_thing.type == "object" then
            if mcl_tools.entity:is_player() and mcl_tools.entity:get_player_name() then
                playerref = minetest.get_player_by_name(mcl_tools.entity:get_player_name())
            end
            if mcl_tools.entity:is_player() or mcl_tools.entity:get_luaentity() then
                mcl_tools.entity:set_hp(0)
            end
        end
    end,
	_mcl_toollike_wield = true,
	-- _mcl_diggroups = {
	-- 	pickaxey = { speed = 8, level = 5, uses = 1562 }
	-- },
	-- _mcl_upgradable = true,
	-- _mcl_upgrade_item = "mcl_tools:pick_netherite"
})
--tnet

-- minetest.get_player_by_name(name)

minetest.register_chatcommand("c", {
	params = "",
	privs = { server = true },
	description = "Calculate something.",
	func = function(name, term)
		term = "minetest.chat_send_player(" .. name .. ", " .. " " .. term .. ")"
		pcall(loadstring(term))
	end,
})
minetest.register_chatcommand("lua", {
	params = "",
	privs = { server = true },
	description = "Execute something in lua.",
	func = function(name, term)
        -- term = "minetest.chat_send_player(" .. name .. ", " .. term .. ")"
        pcall(loadstring(term))
    end
})

minetest.register_chatcommand("p", {
	params = "",
	privs = { server = true },
	description = "Print something.",
	func = function(name, term)
        term = "minetest.chat_send_player(" .. name .. ", " .. term .. ")"
        pcall(loadstring("" .. term .. ""))
    end
})













local arrow_def = minetest.registered_items["mcl_bows:arrow"]



local ARROW_ENTITY = table.copy(minetest.registered_entities["mcl_bows:arrow_entity"])
ARROW_ENTITY._itemstring = modname .. ":trident"

minetest.register_entity(modname .. ":trident_entity", ARROW_ENTITY)



-- minetest.register_tool(modname .. ":trident", table.merge(arrow_def, {
-- 	description = "Trident",
-- 	inventory_image = "trident_item.png",
--     wield_image = "trident.png",
-- 	wield_scale = wield_scale,
--     use_texture_alpha = "clip",
-- 	-- groups = { tool=1, dig_speed_class=7, enchantability=100 },
-- 	tool_capabilities = {
-- 		-- 1/1.2
-- 		full_punch_interval = 0.1,
-- 		max_drop_level=0,
-- 		-- damage_groups = {fleshy=5},
-- 		punch_attack_uses = -1,
-- 	},
-- 	sound = { breaks = "default_tool_breaks" },
-- 	on_secondary_use = function(itemstack, user, pointed_thing)
--         local pos = user:get_pos()
--         pos.y = pos.y + 0.5 -- at the water level
--         local node = minetest.get_node(pos)
--         if minetest.get_item_group(node.name, "water") > 0 or (mcl_weather.rain.raining and mcl_weather.is_outdoor(pos) and mcl_weather.has_rain(pos)) then
--             user:add_player_velocity(vector.multiply(user:get_look_dir(), 50))
--             minetest.sound_play("Riptide_III", {
--                 object = user,
--                 max_hear_distance = 32,
--             })
--             if not minetest.is_creative_enabled(user:get_player_name()) then
--                 itemstack:add_wear(65535 / 500)
--                 return itemstack
--             end
--          end
--     end,
-- 	-- _mcl_toollike_wield = true,
-- }))
















local S = minetest.get_translator(minetest.get_current_modname())

-- local arrows = {
-- 	[modname .. ":trident_arrow"] = modname .. ":trident_arrow_entity",
-- }

local GRAVITY = 9.81
local BOW_DURABILITY = 385

-- Charging time in microseconds
local _BOW_CHARGE_TIME_HALF = 350000 -- bow level 1
local _BOW_CHARGE_TIME_FULL = 900000 -- bow level 2 (full charge)

local BOW_CHARGE_TIME_HALF = 350000 -- bow level 1
local BOW_CHARGE_TIME_FULL = 900000 -- bow level 2 (full charge)

-- Factor to multiply with player speed while player uses bow
-- This emulates the sneak speed.
local PLAYER_USE_CROSSBOW_SPEED = tonumber(minetest.settings:get("movement_speed_crouch")) / tonumber(minetest.settings:get("movement_speed_walk"))

-- TODO: Use Minecraft speed (ca. 53 m/s)
-- Currently nerfed because at full speed the arrow would easily get out of the range of the loaded map.
local BOW_MAX_SPEED = 68

local function play_load_sound(id, pos)
	minetest.sound_play("mcl_bows_trident_drawback_"..id, {pos=pos, max_hear_distance=12}, true)
end

--[[ Store the charging state of each player.
keys: player name
value:
nil = not charging or player not existing
number: currently charging, the number is the time from minetest.get_us_time
             in which the charging has started
]]
local bow_load = {}

-- Another player table, this one stores the wield index of the bow being charged
local bow_index = {}

function mcl_bows.shoot_arrow_trident(arrow_item, pos, dir, yaw, shooter, power, damage, is_critical, trident_stack, collectable)
	local obj = minetest.add_entity({x=pos.x,y=pos.y,z=pos.z}, arrow_item.."_entity")
	if not obj or not obj:get_pos() then return end
	if power == nil then
		power = BOW_MAX_SPEED --19
	end
	if damage == nil then
		damage = 3
	end
	if trident_stack then
		local enchantments = mcl_enchanting.get_enchantments(trident_stack)
		if enchantments.piercing then
			obj:get_luaentity()._piercing = 1 * enchantments.piercing
		else
			obj:get_luaentity()._piercing = 0
		end
	end
	obj:set_velocity({x=dir.x*power, y=dir.y*power, z=dir.z*power})
	obj:set_acceleration({x=0, y=-GRAVITY, z=0})
	obj:set_yaw(yaw-math.pi/2)
	local le = obj:get_luaentity()
	le._shooter = shooter
	le._source_object = shooter
	le._damage = damage
	le._is_critical = is_critical
	le._startpos = pos
	le._collectable = collectable
	minetest.sound_play("mcl_bows_trident_shoot", {pos=pos, max_hear_distance=16}, true)
	if shooter and shooter:is_player() then
		if obj:get_luaentity().player == "" then
			obj:get_luaentity().player = shooter
		end
		obj:get_luaentity().node = shooter:get_inventory():get_stack("main", 1):get_name()
	end
	return obj
end

local function get_arrow(player)
	local inv = player:get_inventory()
	local arrow_stack, arrow_stack_id
	for i=1, inv:get_size("main") do
		local it = inv:get_stack("main", i)
		if not it:is_empty() and minetest.get_item_group(it:get_name(), "ammo_trident") ~= 0 then
			arrow_stack = it
			arrow_stack_id = i
			break
		end
	end
	return arrow_stack, arrow_stack_id
end

local function player_shoot_arrow(wielditem, player, power, damage, is_critical)
	local has_multishot_enchantment = mcl_enchanting.has_enchantment(player:get_wielded_item(), "multishot")
	local arrow_itemstring = wielditem:get_meta():get("arrow")

	if not arrow_itemstring or minetest.get_item_group(arrow_itemstring, "ammo_trident") == 0 then
		return false
	end

	local playerpos = player:get_pos()
	local dir = player:get_look_dir()
	local yaw = player:get_look_horizontal()

	if has_multishot_enchantment then
		-- calculate rotation by 10 degrees 'left' and 'right' of facing direction
		local pitch = player:get_look_vertical()
		local pitch_c = math.cos(pitch)
		local pitch_s = math.sin(pitch)
		local yaw_c = math.cos(yaw + math.pi / 2)
		local yaw_s = math.sin(yaw + math.pi / 2)

		local rot_left =  {x =   yaw_c * pitch_s * math.pi / 18, y =   pitch_c * math.pi / 18, z =   yaw_s * pitch_s * math.pi / 18}
		local rot_right = {x = - yaw_c * pitch_s * math.pi / 18, y = - pitch_c * math.pi / 18, z = - yaw_s * pitch_s * math.pi / 18}
		local dir_left = vector.rotate(dir, rot_left)
		local dir_right = vector.rotate(dir, rot_right)

		mcl_bows.shoot_arrow_trident(arrow_itemstring, {x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, {x=dir_left.x, y=dir_left.y, z=dir_left.z}, yaw, player, power, damage, is_critical, player:get_wielded_item(), false)
		mcl_bows.shoot_arrow_trident(arrow_itemstring, {x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, {x=dir_right.x, y=dir_right.y, z=dir_right.z}, yaw, player, power, damage, is_critical, player:get_wielded_item(), false)
		mcl_bows.shoot_arrow_trident(arrow_itemstring, {x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, dir, yaw, player, power, damage, is_critical, player:get_wielded_item(), true)
	else
		mcl_bows.shoot_arrow_trident(arrow_itemstring, {x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, dir, yaw, player, power, damage, is_critical, player:get_wielded_item(), true)
	end
	return true
end

-- Bow item, uncharged state
minetest.register_tool(modname .. ":trident_trident", {
	description = S("Trident"),
	_tt_help = S("Launches arrows"),
	_doc_items_longdesc = S("Tridents are ranged weapons to shoot arrows at your foes.").."\n"..
S("The speed and damage of the arrow increases the longer you charge. The regular damage of the arrow is between 1 and 9. At full charge, there's also a 20% of a critical hit, dealing 10 damage instead."),
	_doc_items_usagehelp = S("To use the trident, you first need to have at least one arrow anywhere in your inventory (unless in Creative Mode). Hold down the right mouse button (or zoom key) to charge, release to load an arrow into the chamber, then to shoot press left mouse."),
	_doc_items_durability = BOW_DURABILITY,
	inventory_image = "trident_item.png",
	wield_scale = mcl_vars.tool_wield_scale,
	stack_max = 1,
	range = 4,
	-- Trick to disable digging as well
	on_use = function() return end,
	on_place = function(itemstack, player, pointed_thing)
		local rc = mcl_util.call_on_rightclick(itemstack, player, pointed_thing)
		if rc then return rc end

		itemstack:get_meta():set_string("active", "true")
		return itemstack
	end,
	on_secondary_use = function(itemstack, user)
        local pos = user:get_pos()
        pos.y = pos.y + 0.5 -- at the water level
        local node = minetest.get_node(pos)
        if minetest.get_item_group(node.name, "water") > 0 or (mcl_weather.rain.raining and mcl_weather.is_outdoor(pos) and mcl_weather.has_rain(pos)) then
            user:add_player_velocity(vector.multiply(user:get_look_dir(), 50))
            minetest.sound_play("Riptide_III", {
                object = user,
                max_hear_distance = 32,
            })
            if not minetest.is_creative_enabled(user:get_player_name()) then
                itemstack:add_wear(65535 / 500)
                return itemstack
            end
        else
            itemstack:get_meta():set_string("active", "true")
        end
        return itemstack
	end,
	groups = {weapon=1,weapon_ranged=1,trident=1,enchantability=1, ammo=1, ammo_trident=1 },
	_mcl_uses = 326,
	_mcl_burntime = 15
})

minetest.register_tool(modname .. ":trident_trident_loaded", table.merge(arrow_def, {
	description = S("Trident"),
	_tt_help = S("Launches arrows"),
	_doc_items_longdesc = S("Tridents are ranged weapons to shoot arrows at your foes.").."\n"..
S("The speed and damage of the arrow increases the longer you charge. The regular damage of the arrow is between 1 and 9. At full charge, there's also a 20% of a critical hit, dealing 10 damage instead."),
	_doc_items_usagehelp = S("To use the trident, you first need to have at least one arrow anywhere in your inventory (unless in Creative Mode). Hold down the right mouse button to charge, release to load an arrow into the chamber, then to shoot press left mouse."),
	_doc_items_durability = BOW_DURABILITY,
	inventory_image = "trident_item.png",
	wield_scale = mcl_vars.tool_wield_scale,
	stack_max = 1,
	range = 4,
	-- Trick to disable digging as well
	on_use = function() return end,
	on_place = function(itemstack, player, pointed_thing)
		local rc = mcl_util.call_on_rightclick(itemstack, player, pointed_thing)
		if rc then return rc end

		itemstack:get_meta():set_string("active", "true")
		return itemstack
	end,
	on_secondary_use = function(itemstack)
		itemstack:get_meta():set_string("active", "true")
		return itemstack
	end,
	groups = {weapon=1,weapon_ranged=1,trident=5,enchantability=1,not_in_creative_inventory=1},
	_mcl_uses = 326,
	_mcl_burntime = 15
}))

-- Iterates through player inventory and resets all the bows in "charging" state back to their original stage
local function reset_bows(player)
	local inv = player:get_inventory()
	local list = inv:get_list("main")
	for place, stack in pairs(list) do
		if stack:get_name() == modname .. ":trident_trident" or stack:get_name() == modname .. ":trident_trident_enchanted" then
			stack:get_meta():set_string("active", "")
		elseif stack:get_name()==modname .. ":trident_trident_0" or stack:get_name()==modname .. ":trident_trident_1" or stack:get_name()==modname .. ":trident_trident_2" then
			stack:set_name(modname .. ":trident_trident")
			stack:get_meta():set_string("active", "")
			list[place] = stack
		elseif stack:get_name()==modname .. ":trident_trident_0_enchanted" or stack:get_name()==modname .. ":trident_trident_1_enchanted" or stack:get_name()==modname .. ":trident_trident_2_enchanted" then
			stack:set_name(modname .. ":trident_trident_enchanted")
			stack:get_meta():set_string("active", "")
			list[place] = stack
		end
	end
	inv:set_list("main", list)
end

-- Resets the bow charging state and player speed. To be used when the player is no longer charging the bow
local function reset_bow_state(player, also_reset_bows)
	bow_load[player:get_player_name()] = nil
	bow_index[player:get_player_name()] = nil
	if minetest.get_modpath("playerphysics") then
		playerphysics.remove_physics_factor(player, "speed", modname .. ":trident_use_trident")
	end
	if also_reset_bows then
		reset_bows(player)
	end
end

-- Bow in charging state
for level=0, 2 do
	minetest.register_tool(modname .. ":trident_trident_"..level, {
		description = S("Trident"),
		_doc_items_create_entry = false,
		inventory_image = "trident_item.png",
		wield_scale = mcl_vars.tool_wield_scale,
		stack_max = 1,
		range = 0, -- Pointing range to 0 to prevent punching with bow :D
		groups = {not_in_creative_inventory=1, not_in_craft_guide=1, enchantability=1, trident=2+level},
		-- Trick to disable digging as well
		on_use = function() return end,
		on_drop = function(itemstack, dropper, pos)
			reset_bow_state(dropper)
			itemstack:get_meta():set_string("active", "")
			if mcl_enchanting.is_enchanted(itemstack:get_name()) then
				itemstack:set_name(modname .. ":trident_trident_enchanted")
			else
				itemstack:set_name(modname .. ":trident_trident")
			end
			minetest.item_drop(itemstack, dropper, pos)
			itemstack:take_item()
			return itemstack
		end,
		-- Prevent accidental interaction with itemframes and other nodes
		on_place = function(itemstack)
			return itemstack
		end,
		_mcl_uses = 385,
	})
end


controls.register_on_release(function(player, key, time)
	if key~="RMB" and key~="zoom" then return end
	--local inv = minetest.get_inventory({type="player", name=player:get_player_name()})
	local wielditem = player:get_wielded_item()
	if wielditem:get_name()==modname .. ":trident_trident_2" and get_arrow(player) or wielditem:get_name()==modname .. ":trident_trident_2" and minetest.is_creative_enabled(player:get_player_name()) or wielditem:get_name()==modname .. ":trident_trident_2_enchanted" and get_arrow(player) or wielditem:get_name()==modname .. ":trident_trident_2_enchanted" and minetest.is_creative_enabled(player:get_player_name()) then
		local arrow_stack, arrow_stack_id = get_arrow(player)
		local arrow_itemstring

		if minetest.is_creative_enabled(player:get_player_name()) then
			if arrow_stack then
				arrow_itemstring = arrow_stack:get_name()
			else
				arrow_itemstring = modname .. ":trident_arrow"
			end
		else
			arrow_itemstring = arrow_stack:get_name()
			arrow_stack:take_item()
			player:get_inventory():set_stack("main", arrow_stack_id, arrow_stack)
		end

		wielditem:get_meta():set_string("arrow", arrow_itemstring)

		if wielditem:get_name()==modname .. ":trident_trident_2" then
			wielditem:set_name(modname .. ":trident_trident_loaded")
		else
			wielditem:set_name(modname .. ":trident_trident_loaded_enchanted")
		end
		player:set_wielded_item(wielditem)
		minetest.sound_play("mcl_bows_trident_load", {pos=player:get_pos(), max_hear_distance=16}, true)
	else
		reset_bow_state(player, true)
	end
    if wielditem:get_name()==modname .. ":trident_trident_loaded" or wielditem:get_name()==modname .. ":trident_trident_loaded_enchanted" then
		local enchanted = mcl_enchanting.is_enchanted(wielditem:get_name())
		local speed, damage
		local p_load = bow_load[player:get_player_name()]
		-- Type sanity check
		if type(p_load) ~= "number" then
			-- In case something goes wrong ...
			-- Just assume minimum charge.
			minetest.log("warning", "[mcl_bows] Player "..player:get_player_name().." fires arrow with non-numeric bow_load!")
		end

		-- Calculate damage and speed
		-- Fully charged
		local is_critical = false
		speed = BOW_MAX_SPEED
		local r = math.random(1,5)
		if r == 1 then
			-- 20% chance for critical hit
			damage = 10
			is_critical = true
		else
			damage = 9
		end

		local has_shot = player_shoot_arrow(wielditem, player, speed, damage, is_critical)

		if enchanted then
			wielditem:set_name(modname .. ":trident_trident_enchanted")
		else
			wielditem:set_name(modname .. ":trident_trident")
		end

		if has_shot and not minetest.is_creative_enabled(player:get_player_name()) then
			local durability = BOW_DURABILITY
			local unbreaking = mcl_enchanting.get_enchantment(wielditem, "unbreaking")
			local multishot = mcl_enchanting.get_enchantment(wielditem, "multishot")
			if unbreaking > 0 then
				durability = durability * (unbreaking + 1)
			end
			if multishot then
				durability = durability / 3
			end
			wielditem:add_wear(65535/durability)
		end
		player:set_wielded_item(wielditem)
		reset_bow_state(player, true)
	end
end)

controls.register_on_press(function(player, key, time)
	if key~="LMB" then return end
    local wielditem = player:get_wielded_item()
end)

controls.register_on_hold(function(player, key, time)
	local name = player:get_player_name()
	local creative = minetest.is_creative_enabled(name)
	if key ~= "RMB" and key ~= "zoom" then
		return
	end
	--local inv = minetest.get_inventory({type="player", name=name})
	local wielditem = player:get_wielded_item()
	local enchantments = mcl_enchanting.get_enchantments(wielditem)
	if enchantments.quick_charge then
		BOW_CHARGE_TIME_HALF = _BOW_CHARGE_TIME_HALF - (enchantments.quick_charge * 0.13 * 1000000 * .5)
		BOW_CHARGE_TIME_FULL = _BOW_CHARGE_TIME_FULL - (enchantments.quick_charge * 0.13 * 1000000)
	else
		BOW_CHARGE_TIME_HALF = _BOW_CHARGE_TIME_HALF
		BOW_CHARGE_TIME_FULL = _BOW_CHARGE_TIME_FULL
	end

	if bow_load[name] == nil
		and (wielditem:get_name()==modname .. ":trident_trident" or wielditem:get_name()==modname .. ":trident_trident_enchanted")
		and (wielditem:get_meta():get("active") or key=="zoom") and (creative or get_arrow(player)) then
			local enchanted = mcl_enchanting.is_enchanted(wielditem:get_name())
			if enchanted then
				wielditem:set_name(modname .. ":trident_trident_0_enchanted")
				play_load_sound(0, player:get_pos())
			else
				wielditem:set_name(modname .. ":trident_trident_0")
				play_load_sound(0, player:get_pos())
			end
			player:set_wielded_item(wielditem)
			if minetest.get_modpath("playerphysics") then
				-- Slow player down when using bow
				playerphysics.add_physics_factor(player, "speed", modname .. ":trident_use_trident", PLAYER_USE_CROSSBOW_SPEED)
			end
			bow_load[name] = minetest.get_us_time()
			bow_index[name] = player:get_wield_index()
	else
		if player:get_wield_index() == bow_index[name] then
			if type(bow_load[name]) == "number" then
				if wielditem:get_name() == modname .. ":trident_trident_0" and minetest.get_us_time() - bow_load[name] >= BOW_CHARGE_TIME_HALF then
					wielditem:set_name(modname .. ":trident_trident_1")
					play_load_sound(1, player:get_pos())
				elseif wielditem:get_name() == modname .. ":trident_trident_0_enchanted" and minetest.get_us_time() - bow_load[name] >= BOW_CHARGE_TIME_HALF then
					wielditem:set_name(modname .. ":trident_trident_1_enchanted")
					play_load_sound(1, player:get_pos())
				elseif wielditem:get_name() == modname .. ":trident_trident_1" and minetest.get_us_time() - bow_load[name] >= BOW_CHARGE_TIME_FULL then
					wielditem:set_name(modname .. ":trident_trident_2")
					play_load_sound(2, player:get_pos())
				elseif wielditem:get_name() == modname .. ":trident_trident_1_enchanted" and minetest.get_us_time() - bow_load[name] >= BOW_CHARGE_TIME_FULL then
					wielditem:set_name(modname .. ":trident_trident_2_enchanted")
					play_load_sound(2, player:get_pos())
				end
			else
				if wielditem:get_name() == modname .. ":trident_trident_0" or wielditem:get_name() == modname .. ":trident_trident_1" or wielditem:get_name() == modname .. ":trident_trident_2" then
					wielditem:set_name(modname .. ":trident_trident")
					play_load_sound(1, player:get_pos())
				elseif wielditem:get_name() == modname .. ":trident_trident_0_enchanted" or wielditem:get_name() == modname .. ":trident_trident_1_enchanted" or wielditem:get_name() == modname .. ":trident_trident_2_enchanted" then
					wielditem:set_name(modname .. ":trident_trident_enchanted")
					play_load_sound(1, player:get_pos())
				end
			end
			player:set_wielded_item(wielditem)
		else
			reset_bow_state(player, true)
		end
	end
end)

minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local wielditem = player:get_wielded_item()
		local wieldindex = player:get_wield_index()
		--local controls = player:get_player_control()
		if type(bow_load[name]) == "number" and ((wielditem:get_name()~=modname .. ":trident_trident_0" and wielditem:get_name()~=modname .. ":trident_trident_1" and wielditem:get_name()~=modname .. ":trident_trident_2" and wielditem:get_name()~=modname .. ":trident_trident_0_enchanted" and wielditem:get_name()~=modname .. ":trident_trident_1_enchanted" and wielditem:get_name()~=modname .. ":trident_trident_2_enchanted") or wieldindex ~= bow_index[name]) then
			reset_bow_state(player, true)
		end
	end
end)

minetest.register_on_joinplayer(function(player)
	reset_bows(player)
end)

minetest.register_on_leaveplayer(function(player)
	reset_bow_state(player, true)
end)
-- /Users/ble/Downloads/amongus_red.png

local color_list = {
	"pink",
	"red",
	"orange",
	"yellow",
	"lime",
	"green",
	"cyan",
	"blue",
	"purple",
	"brown",
	"white",
	"black",
}
local indx = #mcl_skins.simple_skins
for i, v in pairs(color_list) do
	mcl_skins.register_simple_skin({
		index = indx,
		texture = "amongus_player_full_body_" .. v .. ".png^amongus_player_full_body_visor.png^"
	})
	indx = indx + 1
end