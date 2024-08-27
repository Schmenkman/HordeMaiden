local utils = require("core.utils")
local teleport_logic = require("core.teleport")

local task = {
    name = "Teleport to Helltide",
    should_execute = function()
    local result = not utils.is_in_helltide_zone()
    return result
	end,
    execute = function()
        local teleport_completed = teleport_logic.tp_to_next()
        if teleport_completed then
            if utils.is_in_helltide_zone() then
                return true
            else
                return false
            end
        end
        return false
    end
}

return task