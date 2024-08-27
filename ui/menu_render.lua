local menu = require("ui.menu")

local function render_menu()
    if not menu.main_tree:push("Helltide Maiden Auto") then
        return
    end

    menu.main_enabled:render("Enable Plugin", "Enable or disable this plugin")
    menu.auto_revive:render("Auto Revive", "Automatically revive on death")
    menu.show_task:render("Show Task", "Show current task at top left screen location")
    menu.enable_return_to_center:render("Return to Center", "Automatically return to the maiden when too far away")
    
    if menu.enable_return_to_center:get() then
        menu.show_max_distance_circle:render("Show Max Distance Circle", "Display a circle showing the maximum allowed distance from the maiden")
        menu.max_distance_from_maiden:render("Max Distance From Maiden", "Maximum distance allowed from the maiden before walking back", 2)
        menu.return_delay:render("Return To Circle Time", "Time in seconds before walking back to maiden position", 2)
    end

	menu.path_angle_slider:render("Path Angle", "Adjust the angle for path finding (1-180)", 0)
	
    menu.combat_distance:render("Combat Distance", "Distance for combat engagement (2-25)", 1)
    menu.melee_option:render("Melee Combat", "Enable melee combat mode")
    
    if not menu.melee_option:get() then
        menu.max_attack_range_enabled:render("Enable Max Attack Range", "Fine-tune positioning for ranged combat")
        if menu.max_attack_range_enabled:get() then
            menu.max_attack_range:render("Max Attack Range", "Maximum distance for attacking (2-25)", 1)
        end
    end
    
	menu.insert_hearts:render("Insert Hearts", "Enable automatic heart insertion")
	menu.insert_hearts_onlywithnpcs:render("Insert Hearts Only with NPCs", "Only insert hearts when other players are nearby")
	menu.player_check_distance:render("Player Check Distance", "Radius to check for nearby players when inserting hearts (1-5)", 1)
	
    menu.loot_modes:render("Loot Mode", {"Nothing", "Sell", "Salvage"}, "Choose what to do with looted items")
    
    menu.reset:render("Reset (dont keep on)", "Temporary enable reset mode to reset plugin")

    menu.main_tree:pop()
end

return {
    render_menu = render_menu
}