local menu = require("ui.menu")
local menu_render = require("ui.menu_render")
local graphics_render = require("ui.graphics_render")
local task_manager = require("task_manager")
local settings = require("settings")
local utils = require("core.utils")
local explorer = require("core.explorer")

local task_configs = {
    teleport_to_helltide = { uses_explorer = false, priority = false },
    travel_to_maiden = { uses_explorer = true, priority = false },
    fight_monsters = { uses_explorer = true, priority = false },
    return_to_maiden = { uses_explorer = true, priority = false },
    repair_items = { uses_explorer = true, priority = true },
    sell_items = { uses_explorer = true, priority = true },
    salvage_items = { uses_explorer = true, priority = true },
	insert_hearts = { uses_explorer = true, priority = false }
}

for task_name, config in pairs(task_configs) do
    local task = require("tasks." .. task_name)
    task_manager.register_task(task, config)
end

on_update(function()
    settings:update()
    
    if not settings.enabled then
        return
    end

    local local_player = get_local_player()
    if not local_player then
        return
    end

    local current_task = task_manager.get_current_task()
    
    if settings.auto_revive and local_player:is_dead() then
        revive_at_checkpoint()
	end

    task_manager.execute_tasks()
end)

on_render_menu(menu_render.render_menu)
 
on_render(function()
    if settings.enabled then
        graphics_render.render_graphics()
        
        local current_task = task_manager.get_current_task()
        if current_task then
            local player_pos = get_player_position()
            local draw_pos = vec3:new(player_pos:x(), player_pos:y() - 2, player_pos:z() + 3)
            graphics.text_3d("Current Task: " .. current_task.name, draw_pos, 14, color_white(255))
        end
    end
end)

console.print("Helltide Auto - v3.0 - ALPHA")