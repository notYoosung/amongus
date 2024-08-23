local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

local function play_call(name, pos)
	return minetest.sound_play(name, {
		max_hear_distance = 256,
		pos = pos,

	})
end


--[[local function scandir(directory)
	local i, t, popen = 0, {}, io.popen
	local pfile = assert(popen('ls "' .. directory .. '"'))
	for filename in pfile:lines() do
		i = i + 1
		t[i] = filename
	end	
	pfile:close()
	return t
end	

local custom_calls = scandir("./sounds/custom")
local mc_calls = scandir("./sounds/mc")--]]

local rawitemstring = [[
horns/sounds/custom/horns_custom_amogus.ogg horns/sounds/custom/horns_custom_android_notification_earrape.ogg horns/sounds/custom/horns_custom_augh.ogg horns/sounds/custom/horns_custom_bonk.ogg horns/sounds/custom/horns_custom_bruh.ogg horns/sounds/custom/horns_custom_cave_noise.ogg horns/sounds/custom/horns_custom_discord_leave.ogg horns/sounds/custom/horns_custom_discord_ping.ogg horns/sounds/custom/horns_custom_erm_what_the_sigma.ogg horns/sounds/custom/horns_custom_fart.ogg horns/sounds/custom/horns_custom_fbi_open_up.ogg horns/sounds/custom/horns_custom_huh.ogg horns/sounds/custom/horns_custom_lego_yoda_death.ogg horns/sounds/custom/horns_custom_meme.ogg horns/sounds/custom/horns_custom_metal_pipe.ogg horns/sounds/custom/horns_custom_rick_roll.ogg horns/sounds/custom/horns_custom_shut_up.ogg horns/sounds/custom/horns_custom_taco_bell.ogg horns/sounds/custom/horns_custom_the_animatronic_characters_here_do_get_a_bit_quirky_at_night.ogg horns/sounds/custom/horns_custom_two_hours_later.ogg horns/sounds/custom/horns_custom_womp_womp_womp_womp.ogg horns/sounds/custom/horns_custom_yippee.ogg
]]
local custom_call_names = string.split(string.gsub(string.gsub(rawitemstring, "horns/sounds/custom/", ""), ".ogg", ""),
" ")


local mc_call_names = {
	"Ponder",
	"Sing",
	"Seek",
	"Feel",
	"Admire",
	"Call",
	"Yearn",
	"Dream"
}

for i, v in ipairs(mc_call_names) do
	local on_use = function(itemstack, user, pointed_thing)
		play_call("call" .. tostring(i-1), user:get_pos())
	end
	minetest.register_tool(modname .. ":horn_mc_" .. (mc_call_names[i]:lower() or ""), {
		description = mc_call_names[i],
		image = "goat_horn.png",
		use_texture_alpha = "clip",
		on_secondary_use = on_use,
		on_place = on_use,
	})
end


local function capitalize(str)
	if #str <= 1 then return str:upper() end
	return str:sub(1, 1):upper() .. str:sub(2, str:len())
end


for i, v in ipairs(custom_call_names) do
	local call_dir = custom_call_names[i] or "unnamed"
	call_dir = call_dir:trim()
	local call_name = call_dir:gsub("horns_custom_", "")

	local on_use = function(itemstack, user, pointed_thing)
		play_call(call_name, user:get_pos())
	end
	minetest.register_tool(modname .. ":horn_custom_" .. call_name, {
		description = call_name:gsub("_", " "),
		image = "goat_horn.png",
		use_texture_alpha = "clip",
		on_secondary_use = on_use,
		on_place = on_use,
	})
end
