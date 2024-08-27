local evade_tool = {}
local settings = require("settings")

function evade_tool.initialize()
    local initialized_evade_db = false
    on_update(function ()
        if initialized_evade_db then
            return
        end
        
        local rectangle_spell_identifier = "Blood Maiden Bolt"
        local rectangle_spell_particles = {"fxKit_damaging_burstAttractor_fire_parent"}
        local rectangle_spell_width = settings.evade_rectangle_spell_width
        local rectangle_spell_length = settings.evade_rectangle_spell_length
        local rectangle_spell_color = color.new(0, 0, 255, 255) -- RGBA: Blue
        local rectangle_spell_dynamic = false
        local rectangle_spell_danger_level = danger_level.high
        local rectangle_spell_is_projectile = true
        local rectangle_spell_speed = settings.evade_rectangle_spell_speed
        local rectangle_spell_max_time_alive = settings.evade_rectangle_spell_max_time_alive
        local rectangle_spell_set_to_player_pos_on_creation = false
        local rectangle_spell_set_to_player_pos_delay = settings.evade_rectangle_spell_set_to_player_pos_delay

        evade.register_rectangular_spell(rectangle_spell_identifier, rectangle_spell_particles, rectangle_spell_width,
                                         rectangle_spell_length, rectangle_spell_color, rectangle_spell_dynamic,
                                         rectangle_spell_danger_level, rectangle_spell_is_projectile, rectangle_spell_speed,
                                         rectangle_spell_max_time_alive, rectangle_spell_set_to_player_pos_on_creation, rectangle_spell_set_to_player_pos_delay)

        initialized_evade_db = true
    end)
end

return evade_tool