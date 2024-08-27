local utils = require("core.utils")
local menu = require("ui.menu")
local hearts = require("core.hearts")
local explorer = require("core.explorer")
local settings = require ("settings")

local task = {
    name = "Insert Hearts",

    should_execute = function()
        return utils.is_in_helltide_zone() and 
               utils.is_near_maiden(settings.player_near_maiden_distance) and
               hearts.has_available_hearts() and
               menu.insert_hearts:get() and
               utils.get_closest_enemy() == nil and
               utils.is_player_in_maiden_circle() and not hearts.heart_inserted_since_last_boss
    end,

    execute = function()
        local current_time = os.clock()

        if menu.insert_hearts_onlywithnpcs:get() then
            local nearby_players = hearts.check_players_in_range()
            if nearby_players == 0 then
                console.print("Heart Task: No other players nearby, skipping heart insertion")
                return
            end
        end

        hearts.check_boss_dead(current_time)

        if hearts.start_insert_process(current_time) then
            hearts.try_insert_heart()
        end

        hearts.handle_insert_waiter(current_time)
    end,

    on_enter = function()
        console.print("Heart Task: Entering Insert Hearts task")
    end,

    on_exit = function()
        console.print("Heart Task: Exiting Insert Hearts task")
        hearts.reset()
    end
}

return task