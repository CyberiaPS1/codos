
function AnimationLibrary() constructor {
	
	library = {};
	
	
	static flush = function(asset_tag = undefined) {
		if is_undefined(asset_tag) {
			// Flush library
			delete lib;
			lib = {};
		}
		
		else {
			// Flush individual dictionary
			delete lib[$ asset_tag];
		}
	};
	
	static __get = function(name, asset_tag) {
		if !variable_struct_exists(library, asset_tag)
			__load(asset_tag);
		
		var dictionary = library[$ asset_tag];
		if !variable_struct_exists(dictionary, name) {
			show_debug_message("[AnimationLibrary.__get()] Animation \""+asset_tag+"__"+name+"\" does not exist...");
			return undefined;
		}
		
		return dictionary[$ name].__clone();
	};
	
	static __load = function(asset_tag) {
		library[$ asset_tag] = {};
		var dictionary = library[$ asset_tag];
		
		// "Dictionaries"
		switch asset_tag {
			
			case "obj_player":
				dictionary[$ "stand"] = new AnimationData_Strip({
					name : "stand",
					sprite : sprtest_player_run,
					mask : sprtest_player_mask,
					start : 0
				});
				dictionary[$ "walk"] = new AnimationData_Strip({
					name : "walk",
					sprite : sprtest_player_run,
					mask : sprtest_player_mask,
					start : 0,
					length : 2,
					framespeed : 10
				});
			break;
			
			case "obj_slime":
			break;
		}
	};
	
}



function AnimationMgr() constructor {
	__pid = other.id;
	__asset_tag = object_get_name(other.object_index);
	__color = "";
	__r = 0;
	__g = 0;
	__b = 0;
	__animation = new AnimationData();
	
	
	static draw = function(x, y, face) {
		__animation.draw(x, y, face, __r, __g, __b);
	};
	
	static ended = function() {
		return __animation.ended();
	};
	
	static set = function(name, override_tag = undefined) {
		delete __animation;
		if is_undefined(override_tag) override_tag = __asset_tag;
		var animation = global.animationLibrary.__get(name, override_tag);
		
		if !is_undefined(animation) {
			__animation = animation;
			__pid.mask_index = __animation.mask;
			__animation.__set_color(__color);
		}
		
	};
	
	static set_color = function(color = "", r = 0, g = 0, b = 0) {
		__color = color;
		
		if __color == "custom" {
			__r = r;
			__g = g;
			__b = b;
		}
		
		__animation.__set_color(__color);
	};
	
	static step = function(modifier = 1) {
		__animation.step(modifier);
	};
}



function AnimationData() constructor {
	name = "";
	sprite = undefined;
	mask = undefined;
	start = 0;
	length = 1;
	framespeed = 0;
	loops = true;
	// Internal
	__T = AnimationData;
	__sprite = undefined;
	__frame = 0;
	__ended = false;
	__increment = 0;
	__x_offset = 0;
	__y_offset = 0;
	
	
	/// Overrides
	//-- Override childrens functions if needed.
	
	static draw = function(x, y, face = 1) {};
	
	static __step = function() {};
	
	
	/// Functions
	
	static ended = function() {
		return __ended;
	};
	
	static step = function(modifier) {
		__frame += __increment * modifier;
		__ended = __frame >= length;
		
		if __ended and loops
			__frame = 0;
		
		__step();
	};
	
	
	static __clone = function() {
		return new __T(self);
	};
	
	static __set_color = function(color = "") {
		if color != "" color = "_" + color;
		__sprite = asset_get_index(sprite_get_name(sprite) + color);
	};
	
	static __setup = function(data) {
		var names = variable_struct_get_names(data);
		
		var i = 0; repeat array_length(names) {
			var name = names[i++];
			self[$ name] = data[$ name];
		}
		
		__set_color();
		__increment = framespeed == 0 ? 0 : framespeed / TICKRATE;
		__x_offset = sprite_get_xoffset(mask);
		__y_offset = sprite_get_yoffset(mask);
	};
	
}



function AnimationData_Sheet(data) : AnimationData() constructor {
	left = 0;
	top = 0;
	width = 0;
	height = 0;
	gridsize = 0;
	// Internal
	__T = AnimationData_Sheet;
	__xx = left;
	__yy = top;
	// Setup
	__setup(data);
	if gridsize == 0 gridsize = length;
	
	
	/// Overrides
	
	static draw = function(x, y, face = 1) {
		draw_sprite_part_ext(__sprite, 0, __xx, __yy, width, height, x - __x_offset, y - __y_offset, face, 1, c_white, 1);
	};
	
	static __step = function() {
		var frame = floor(__frame);
		
		__xx = left + ((frame mod gridsize) * width);
		__yy = top + ((frame div gridsize) * height);
	};
}



function AnimationData_Strip(data) : AnimationData() constructor {
	// Internal
	__T = AnimationData_Strip;
	//Setup
	__setup(data);
	
	
	/// Overrides
	
	static draw = function(x, y, face = 1) {
		draw_sprite_ext(__sprite, __frame, x, y, face, 1, 0, c_white, 1);
	};
}

