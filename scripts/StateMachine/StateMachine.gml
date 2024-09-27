
function StateMachine() constructor {
	__pid = other.id;
	__state = undefined;
	__states = {};
	__triggers = {};
	__context = {};
	
	
	/// Definitions
	
	static define_state = function(name, state) {
		if !variable_struct_exists(__states, name) {
			__states[$ name] = state;
			var __state = __states[$ name];
			
			if variable_struct_exists(__state, "start")
				__state.start = method(__pid, __state.start);
			else
				__state.start = event_null;
			
			if variable_struct_exists(__state, "step")
				__state.step = method(__pid, __state.step);
			else
				__state.step  = event_null;
			
			if variable_struct_exists(__state, "stop")
				__state.stop = method(__pid, __state.stop);
			else
				__state.stop  = event_null;
			
			
			// anim setup
			/*
			if (!is_array(__state.anim)) {
				__state.anim = [__state.anim];
			}
			
			// insert state buffers
			if ( !variable_struct_exists(__state, "canBuffer") ) {
				__state.canBuffer = false;
			}
			if ( !variable_struct_exists(__state, "canBeBuffered") ) {
				__state.canBeBuffered = false;
			}
			*/
		}
		return self;
	};
	
	
	static define_trigger = function(name, from, to, condition = event_true) {
		if !is_array(from) from = [from];
		
		var i = 0; repeat array_length(from) {
			var state = from[i++];
			
			if !variable_struct_exists(__triggers, state)
				__triggers[$ state] = {};
			
			if !variable_struct_exists(__triggers[$ state], name)
				__triggers[$ state][$ name] = [];
			
			array_push(__triggers[$ state][$ name], [to, condition]);
		}
		
		return self;
	};
	
	
	/// Methods
	
	static start = function(name) {
		stop();
		
		__state = name;
		__states[$ __state].start(__context);
	};
	
	static step = function() {
		if is_undefined(__state) return;
		
		__states[$ __state].step(__context);
	};
	
	static stop = function() {
		if is_undefined(__state) return;
		
		__states[$ __state].stop(__context);
		__state = undefined;
		delete __context;
		__context = {};
	};
	
	static trigger = function(name) {
		if variable_struct_exists(__triggers[$ __state], name) {
			var triggers = __triggers[$ __state][$ name];
			
			var i = 0; repeat array_length(triggers) {
				var trigger = triggers[i++];
				
				if trigger[1]() {
					start(trigger[0]);
					return;
			} }
		}
	};
	
	
	/// Manage
	
	static clean_up = function() {
		delete __states;
		delete __transitions;
	};
}