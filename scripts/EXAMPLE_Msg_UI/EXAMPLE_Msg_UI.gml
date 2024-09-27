
function __consume_obj_char_card(sender, msgId, msgData) {	
	switch msgId {
		case "hover":
			var isArena = msgData.interfaceName == INTERFACE_ARENA;
			var element = msgData.element;
			var index = is_undefined(element) ? -1 : element.index;
			
			
			if !isArena or index == -1 or element.side != side {
				var interface = global.ui.get(INTERFACE_ARENA);
				var selected = interface.selected;
				if selected > -1 and interface.elements[selected].side == side {
					data = interface.elements[selected].data;
				}
				else {
					var actor = global.admin.combat.actors[0];
					if actor.iChar.side == side
						data = actor;
					else
						data = undefined;
				}
			}
			
			else {
				data = element.data;
			}
			
		break;
	}
}




function __consume_obj_barracks(sender, msgId, msgData) {
	switch msgId {
		case "select_character":
			if msgData.interface != INTERFACE_BARRACKS return;
			show_debug_message("Index: "+string(msgData.index));
			if selected > -1 {
				elements[selected].isVisible = true;
				selected = -1;
			}
			selected = msgData.index;
			elements[msgData.index].isVisible = false;
		break;
			
		case "deselect_character":
			if selected > -1 {
				elements[selected].isVisible = true;
				selected = -1;
			}
		break;
	}
}

function __consume_mouse_context(sender, msgId, msgData) {
	switch msgId {
		case "select_character":
			if !is_undefined(element) instance_destroy(element);
		
			var newElement = undefined;
			with msgData newElement = instance_copy(false);
			element = newElement;
			element.isHovered = false;
			element.isValid = false;
			element.isVisible = true;
		break;
			
		case "deselect_character":
			if !is_undefined(element) instance_destroy(element);
		break;
	}
}