
function Doodle() constructor {
	
	static draw = function() {		
		if global.debug
			with objass_wall event_perform(ev_draw, 0);
		
		with obj_player event_perform(ev_draw, 0);
	};
}
