local utils = require("core.utils")
local menu = require("ui.menu")
local explorer = require("core.explorer")

local task = {
    name = "Return to Maiden",

    should_execute = function()
        if not menu.enable_return_to_center:get() then return false end

        local return_delay = menu.return_delay:get()

        return utils.is_in_helltide_zone() and 
               utils.helltide.maiden_arrivalstate == 1 and 
               utils.is_outside_circle_long_enough(return_delay) and 
               utils.get_closest_enemy() == nil
    end,

    execute = function()
        local maiden_position = utils.maiden_position()
        explorer:set_custom_target(maiden_position)
        explorer:move_to_target()
    end,

    on_enter = function()
        local maiden_position = utils.maiden_position()
        explorer:set_custom_target(maiden_position)
    end,

    on_exit = function()
        explorer:clear_path_and_target()
    end
}

return task