local menu = require("ui.menu")
local utils = require("core.utils")
local teleport_logic = require("core.teleport")
local settings = require("settings")
local enums = require("data.enums")

local function render_graphics()
    local local_player = get_local_player()
    if not local_player then
        return
    end
    local player_position = local_player:get_position()

    if not menu.main_enabled:get() then
        return
    end

    local color_red = color.new(255, 0, 0, 255)
    local color_white = color.new(255, 255, 255, 255)
    local color_yellow = color.new(255, 255, 0, 255)
    
    if menu.enable_return_to_center:get() and menu.show_max_distance_circle:get() then
        local maiden_position = utils.maiden_position()
        if utils.helltide.maiden_arrivalstate == 1 and maiden_position then
            local max_distance = menu.max_distance_from_maiden:get()
            graphics.circle_3d(maiden_position, max_distance, color_yellow, 1)
        end
    end
end

return {
    render_graphics = render_graphics
}