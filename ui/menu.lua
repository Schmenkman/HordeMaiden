local plugin_label = "helltide_maiden_auto_plugin_"
local menu_elements =
{
    main_enabled = checkbox:new(false, get_hash(plugin_label .. "main_enabled")),
    auto_revive = checkbox:new(true, get_hash(plugin_label .. "auto_revive")),
    show_task = checkbox:new(true, get_hash(plugin_label .. "show_task")),
    reset = checkbox:new(false, get_hash(plugin_label .. "reset")),
    enable_return_to_center = checkbox:new(true, get_hash(plugin_label .. "enable_return_to_center")),
    show_max_distance_circle = checkbox:new(false, get_hash(plugin_label .. "show_max_distance_circle")),
    max_distance_from_maiden = slider_float:new(5.0, 20.0, 10.0, get_hash(plugin_label .. "max_distance_from_maiden")),
    return_delay = slider_float:new(1.0, 15.0, 5.0, get_hash(plugin_label .. "return_delay")),
    combat_distance = slider_float:new(2.0, 50.0, 25.0, get_hash(plugin_label .. "combat_distance")),
	max_attack_range_enabled = checkbox:new(false, get_hash(plugin_label .. "max_attack_range_enabled")),
    max_attack_range = slider_float:new(2.0, 15.0, 10.0, get_hash(plugin_label .. "max_attack_range")),
    melee_option = checkbox:new(false, get_hash(plugin_label .. "melee_option")),
    loot_modes = combo_box:new(0, get_hash(plugin_label .. "loot_modes")),
    main_tree = tree_node:new(0),
	path_angle_slider = slider_int:new(1, 180, 10, get_hash(plugin_label .. "path_angle_slider")),
	insert_hearts = checkbox:new(false, get_hash(plugin_label .. "insert_hearts")),
	insert_hearts_onlywithnpcs = checkbox:new(false, get_hash(plugin_label .. "insert_hearts_onlywithnpcs")),
	player_check_distance = slider_float:new(1.0, 5.0, 1.0, get_hash(plugin_label .. "player_check_distance")),
}
return menu_elements