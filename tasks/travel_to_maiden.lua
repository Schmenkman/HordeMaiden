local utils = require("core.utils")
local explorer = require("core.explorer")

local task = {
    name = "Travel to Maiden",
    should_execute = function()
        local result = utils.is_in_helltide_zone() and 
                       utils.helltide.maiden_arrivalstate == 0 and 
                       not utils.get_closest_enemy()
        return result
    end,
    execute = function()
        local player_position = get_player_position()
        local current_time = os.clock()
        
        local maiden_position = utils.maiden_position()
        if not maiden_position then
            console.print("Error: No Maiden position")
            return false
        end

	if not explorer:get_current_target() or explorer:get_current_target() ~= maiden_position then
            explorer:set_custom_target(maiden_position)
            console.print(string.format("Custom target set: %.2f, %.2f, %.2f", maiden_position:x(), maiden_position:y(), maiden_position:z()))
        end

        if explorer.check_arrival(maiden_position, 5) then
            console.print("Arrived at Maiden")
            utils.helltide.maiden_arrivalstate = 1
        end
    end,
	on_enter = function()
        -- Set up any necessary state for this task
        local maiden_position = utils.maiden_position()
        if maiden_position then
            explorer:set_custom_target(maiden_position)
        end
    end,
    on_exit = function()
        -- Clean up any task-specific state
        explorer:clear_path_and_target()
    end
}

return task