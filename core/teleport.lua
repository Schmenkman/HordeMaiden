local teleport_logic = {}

local settings = require("settings")
local enums = require("data.enums")

teleport_logic.helltide_tps = enums.teleport_helltide_locations

local current_index = 1
local last_position = nil
local stable_position_count = 0
local stable_position_threshold = settings.teleport_stable_position_count

local current_location = teleport_logic.helltide_tps[1].name
local next_location = teleport_logic.helltide_tps[2].name

local teleport_state = "idle"
local teleport_start_time = 0

function teleport_logic.get_next_teleport_location()
    return next_location
end

function teleport_logic.tp_to_next()
    local current_time = os.time()
    local current_world = world.get_current_world()
    if not current_world then
        return false
    end

    local world_name = current_world:get_name()
    local local_player = get_local_player()
    if not local_player then
        return false
    end

    local current_position = local_player:get_position()

    if teleport_state == "idle" then
        local current_tp = teleport_logic.helltide_tps[current_index]
        teleport_to_waypoint(current_tp.id)
        teleport_state = "initiated"
        teleport_start_time = current_time
        last_position = current_position
        return false
    elseif teleport_state == "initiated" then
        if current_time - teleport_start_time > settings.teleport_timeout then
            teleport_state = "idle"
            return false
        elseif world_name:find("Limbo") then
            teleport_state = "in_limbo"
            return false
        end
    elseif teleport_state == "in_limbo" and not world_name:find("Limbo") then
        teleport_state = "exited_limbo"
        last_position = current_position
        stable_position_count = 0
        return false
    elseif teleport_state == "exited_limbo" then
        if last_position and current_position:dist_to(last_position) < settings.teleport_stable_position_distance then
            stable_position_count = stable_position_count + 1
            if stable_position_count >= stable_position_threshold then
                current_index = current_index % #teleport_logic.helltide_tps + 1
                current_location = teleport_logic.helltide_tps[current_index].name
                next_location = teleport_logic.helltide_tps[current_index % #teleport_logic.helltide_tps + 1].name
                teleport_state = "idle"
                return true
            end
        else
            stable_position_count = 0
        end
    end

    last_position = current_position
    return false
end

function teleport_logic.get_current_location_name()
    return current_location
end

function teleport_logic.reset()
    teleport_state = "idle"
    last_position = nil
    stable_position_count = 0
end

function teleport_logic.get_teleport_state()
    return teleport_state
end

return teleport_logic