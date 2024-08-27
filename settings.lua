local menu = require("ui.menu")

local settings = {
    -- User-configurable settings
    enabled = false,
    auto_revive = true,
    return_to_center = true,
    max_distance_from_maiden = 10.0,
    return_delay = 5.0,
    loot_mode = 0,  -- 0: Nothing, 1: Sell, 2: Salvage

    -- Constants that might change based on balance or gameplay updates
    stable_position_threshold = 10,
    active_spell_cooldown = 10000, -- milliseconds
    reset_cooldown = 200000, -- milliseconds
    mount_animation_time = 2.0, -- seconds
    player_near_maiden_distance = 8.0,
    recently_revived_cooldown = 5,
    loot_distance_threshold = 1,
    loot_cooldown = 2000, -- milliseconds
    item_blacklist_threshold = 200,
    pathfinder_threshold = 1.1,
    distance_check_interval = 4.0, -- seconds
    distance_check_stuck_threshold = 1.0,
    distance_check_stuck_count = 55,
    helper_text_duration = 20.0, -- seconds

    -- Evade settings
    evade_rectangle_spell_width = 1.5,
    evade_rectangle_spell_length = 5.0,
    evade_rectangle_spell_speed = 10.0,
    evade_rectangle_spell_max_time_alive = 1.0,
    evade_rectangle_spell_set_to_player_pos_delay = 0.5,

    -- Teleport settings
    teleport_stable_position_count = 10,
    teleport_stable_position_distance = 1,
    teleport_timeout = 1,

    -- Explorer Settings
    path_angle = 10, -- degrees
	
	--Flags
    has_interacted = false,
	interact_time = 0,
    reset_interact_time = 0,
    portal_interact_time = 0

}

function settings:update()
    self.enabled = menu.main_enabled:get()
    self.auto_revive = menu.auto_revive:get()
    self.return_to_center = menu.enable_return_to_center:get()
    self.max_distance_from_maiden = menu.max_distance_from_maiden:get()
    self.return_delay = menu.return_delay:get()
    self.loot_mode = menu.loot_modes:get()
    self.path_angle = menu.path_angle_slider:get()
end

return settings