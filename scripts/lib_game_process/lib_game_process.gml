

function proc_game() {
	var ui = global.uis[CLOCK.GAME];
	var interface = ui.active;
	var ui_element = gf_get_hovered(ui);
	
	var clock = global.clocks[CLOCK.GAME];
	var action_press = IotaGetInput(BIND_MAIN__ACTION_PRESS);
	var action_release = IotaGetInput(BIND_MAIN__ACTION_RELEASE);
	if action_press global.inputs[$ "game_action_hold"] = true;
	if action_release global.inputs[$ "game_action_hold"] = false;
	var action_hold = global.inputs[$ "game_action_hold"];
	
	//show_debug_message("timer: "+string(IotaGetInput("test")));
	
	
	if is_undefined(ui_element) {
		interface.hover();
	} else {
		if interface.name == ui_element.interface {
			interface.hover(ui_element.index);
		}
	}
	
	if action_press {
		if !is_undefined(ui_element) {
			broadcast(self, "party_select", "select_character", ui_element);
		}
		else broadcast(self, "party_select", "deselect_character", ui_element);
	}
}