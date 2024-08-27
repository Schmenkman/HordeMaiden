local utils = require("core.utils")
local menu = require("ui.menu")
local explorer = require("core.explorer")

local hearts = {
    waiter_interval = 10.0,
    waiter_elapsed = 0,
    last_waiter_time = 0,
    seen_boss_dead = false,
    seen_boss_dead_time = 0,
    heart_inserted_since_last_boss = false,
}

function hearts.reset()
    hearts.waiter_elapsed = 0
    hearts.last_waiter_time = 0
    hearts.seen_boss_dead = false
    hearts.seen_boss_dead_time = 0
    hearts.heart_inserted_since_last_boss = false
end

function hearts.has_available_hearts()
    return get_helltide_coin_hearts() > 0
end

function hearts.check_players_in_range()
    local maiden_position = utils.maiden_position()
    if not maiden_position then return 0 end

    local player_check_radius = menu.player_check_distance:get()
    local player_actors = actors_manager.get_all_actors()
    local count_players_near = 0
    
    for _, obj in ipairs(player_actors) do
        local position = obj:get_position()
        local obj_class = obj:get_character_class_id()
        local distance_maidenposcenter_to_player = position:squared_dist_to_ignore_z(maiden_position)
        if obj_class > -1 and distance_maidenposcenter_to_player <= (player_check_radius * player_check_radius) then
            count_players_near = count_players_near + 1
        end
    end
    
    return count_players_near - 1
end

function hearts.check_boss_dead(current_time)
    if current_time - hearts.seen_boss_dead_time > 30.0 then
        local enemies = actors_manager.get_all_actors()
        for _, obj in ipairs(enemies) do
            local name = string.lower(obj:get_skin_name())
            if obj:is_dead() and obj:is_enemy() and name == "s04_demon_succubus_miniboss" and not hearts.seen_boss_dead then
                hearts.seen_boss_dead = true
                hearts.heart_inserted_since_last_boss = false
                console.print("Heart Task: Recognised Dead Boss, Re-Enabling Hearts Insert Logic")
                hearts.seen_boss_dead_time = current_time
                return true
            end
        end
    end
    return false
end

function hearts.start_insert_process(current_time)
    console.print("Heart Task: Process Triggered - Inserting Heart")
    local maiden_position = utils.maiden_position()
    if maiden_position then
        explorer:set_custom_target(maiden_position)
        explorer:move_to_target()
    else
        console.print("Heart task: Error - Cannot insert heart, maiden position unknown")
        return false
    end
    hearts.last_waiter_time = current_time
    hearts.waiter_elapsed = hearts.waiter_interval
    return true
end

function hearts.handle_insert_waiter(current_time)
    if current_time - hearts.last_waiter_time > hearts.waiter_interval then
        console.print("Heart Task: Cooldown lapsed - Ready for next insertion")
        hearts.waiter_elapsed = 0
        return true
    else
        hearts.waiter_elapsed = hearts.waiter_elapsed - 0.1
        return false
    end
end

function hearts.try_insert_heart()
    local current_hearts = get_helltide_coin_hearts()
    if current_hearts > 0 and not hearts.heart_inserted_since_last_boss then
        local actors = actors_manager.get_all_actors()
        for _, actor in ipairs(actors) do
            local name = string.lower(actor:get_skin_name())
            if name == "S04_SMP_Succuboss_Altar_Rubble" then
                console.print("Heart Task: Interacting with Altar - Trying to insert heart")
                local success = interact_object(actor)
                if success then
                    hearts.heart_inserted_since_last_boss = true
                    console.print("Heart Task: Successfully inserted a heart. Waiting for next boss cycle.")
                end
                return success
            end
        end
    else
        if hearts.heart_inserted_since_last_boss then
            console.print("Heart Task: Heart already inserted for this boss cycle. Waiting for next boss.")
        else
            console.print("Heart Task: No hearts available, stopping insertion process")
        end
    end
    return false
end

return hearts