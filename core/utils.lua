local utils = {}

local settings = require("settings")
local enums = require("data.enums")
local menu = require("ui.menu")

-- Constants
local unstuck_target_distance = 15
local grid_size = 2.0

-- Helltide logic
utils.helltide = {
    zone_name = "Unknown",
    player_in_zone = 0,
    maiden_arrivalstate = 0,
    final_maidenpos = nil,
    zone_pin = 0,
    maidenpos = {},
}

utils.is_outside_circle = false
utils.outside_circle_time = 0
utils.is_recently_revived_at_checkpoint = false
utils.last_checkpoint_revival_time = 0

function utils.table_length(table_in)
    local count = 0
    for _ in pairs(table_in) do
        count = count + 1
    end
    return count
end

function utils.distance_to(target)
    local player_pos = get_player_position()
    local target_pos

    if target.get_position then
        target_pos = target:get_position()
    elseif target.x then
        target_pos = target
    end

    return player_pos:dist_to(target_pos)
end

function utils.round(num, num_decimal_places)
    local mult = 10 ^ (num_decimal_places or 0)
    return math.floor(num * mult + 0.5) / mult
end

function utils.random_element(tb)
    local keys = {}
    for k in pairs(tb) do
        table.insert(keys, k)
    end
    return tb[keys[math.random(#keys)]]
end

function utils.player_in_zone(zname)
    return get_current_world():get_current_zone_name() == zname
end

function utils.get_time_ms()
    return os.clock() * 1000
end

function utils.is_in_helltide_zone()
    local local_player = get_local_player()
    if not local_player then return false end

    local buffs = local_player:get_buffs()
    if not buffs then return false end

    local found_player_in_helltide_zone = false
    local found_player_is_mounted = false

    for _, buff in ipairs(buffs) do
        if buff.name_hash == 1066539 then  -- player buff name during helltide zone equals to "UberSubzone_TrackingPower"
            found_player_in_helltide_zone = true
        end
        if buff.name_hash == 1924 then  -- player buff name during mount state
            found_player_is_mounted = true
        end
    end

    if found_player_is_mounted and utils.helltide.player_in_zone == 1 and not found_player_in_helltide_zone then
        utils.helltide.player_in_zone = 1
        return true
    else
        if found_player_in_helltide_zone then
            utils.helltide.player_in_zone = 1
            return true
        else
            if utils.helltide.maiden_arrivalstate == 1 and found_player_in_helltide_zone then
                utils.helltide.player_in_zone = 1
                return true
            else
                utils.helltide.player_in_zone = 0
                return false
            end
        end
    end
end

function utils.get_closest_enemy()
    local elite_only = settings.elites_only
    local player_pos = get_player_position()
    local combat_range = menu.combat_distance:get()
    
    local enemies = target_selector.get_near_target_list(player_pos, combat_range)
    local closest_elite, closest_normal
    local min_elite_dist, min_normal_dist = math.huge, math.huge

    for _, enemy in pairs(enemies) do
        local dist = player_pos:dist_to(enemy:get_position())
        local is_elite = enemy:is_elite() or enemy:is_champion() or enemy:is_boss()

        if is_elite then
            if dist < min_elite_dist then
                closest_elite = enemy
                min_elite_dist = dist
            end
        elseif not elite_only then
            if dist < min_normal_dist then
                closest_normal = enemy
                min_normal_dist = dist
            end
        end
    end

    return closest_elite or (not elite_only and closest_normal) or nil
end

function utils.is_near_maiden(distance_threshold)
    local maiden_position = utils.maiden_position()
    if not maiden_position then
        return false
    end
    
    local player_position = get_player_position()
    local distance_to_maiden = player_position:dist_to(maiden_position)
    
    return distance_to_maiden <= distance_threshold
end

function utils.table_index_of(tbl, value)
    for i, v in ipairs(tbl) do
        if v == value then
            return i
        end
    end
    return nil
end

function utils.is_player_in_maiden_circle()
    local maiden_position = utils.maiden_position()
    if not maiden_position then return false end

    local player_position = get_player_position()
    local distance_from_maiden = player_position:dist_to(maiden_position)
    local max_distance = menu.max_distance_from_maiden:get()

    return distance_from_maiden <= max_distance
end

local outside_circle_time = 0

function utils.is_outside_circle_long_enough(return_delay)
    if not utils.is_player_in_maiden_circle() then
        local current_time = os.time()
        if outside_circle_time == 0 then
            outside_circle_time = current_time
            return false
        elseif current_time - outside_circle_time > return_delay then
            return true
        end
    else
        outside_circle_time = 0
    end
    return false
end

function utils.get_town_portal()
    local actors = actors_manager:get_all_actors()
    for _, actor in pairs(actors) do
        local name = actor:get_skin_name()
        if name == enums.npc_names.portal then
           return actor
        end
    end
end

function utils.get_blacksmith()
    local actors = actors_manager:get_all_actors()
    for _, actor in pairs(actors) do
        local name = actor:get_skin_name()
        if name == enums.npc_names.blacksmith then
            console.print("blacksmith location found: " .. name)
            return actor
        end
    end
    --console.print("No blacksmith found")
    return nil
end

function utils.get_jeweler()
    local actors = actors_manager:get_all_actors()
    for _, actor in pairs(actors) do
        local name = actor:get_skin_name()
        if name == enums.npc_names.jeweler then
            local position = actor:get_position()
            console.print(string.format("Jeweler location found: %s at position: (x: %f, y: %f, z: %f)", name, position:x(), position:y(), position:z()))
            return actor
        end
    end
    --console.print("No jeweler found")
    return nil
end

function check_for_buff(buff_id)
    local local_player = get_local_player()
    if not local_player then return false end
    
    local buffs = local_player:get_buffs()
    if not buffs then return false end
    
    for _, buff in ipairs(buffs) do
        if buff.name_hash == buff_id then
            return true
        end
    end
    
    return false
end

function utils.maiden_position()
    local world_instance = world.get_current_world()
    if world_instance then
        utils.helltide.zone_name = world_instance:get_current_zone_name()
    end

    local maiden_position = enums.helltide_maiden_positions[utils.helltide.zone_name]
    
    if not maiden_position then
        console.print("Warning: No maiden position found for zone " .. utils.helltide.zone_name)
        return nil
    end

    return maiden_position
end

function utils.is_near_maiden(distance_threshold)
    local maiden_position = utils.maiden_position()
    if not maiden_position then
        return false
    end
    
    local player_position = get_player_position()
    local distance_to_maiden = player_position:dist_to(maiden_position)
    
    return distance_to_maiden <= distance_threshold
end

return utils