
function Display() constructor {
	
	/// CONFIG
	RES_W = 640;
	RES_H = 360;
	PORT_W = 1920;
	PORT_H = 1080;
	fullscreen = false;
	
	/// INIT
	display_set_gui_size(PORT_W, PORT_H);
	scale = PORT_H/RES_H;
	apply_settings(RES_W, RES_H);
	
	
	
	static apply_settings = function(w, h) {
		var r = room_first;
		while room_exists(r) {
			room_set_view_enabled(r, true);
			room_set_camera(r, 0, camera_create_view(0, 0, w, h));
			room_set_viewport(r, 0, true, 0, 0, PORT_W, PORT_H);
			r = room_next(r);
		}
		
		view_camera[0] = camera_create_view(0, 0, w, h);
		view_xport[0] = 0;
		view_yport[0] = 0;
		view_wport[0] = PORT_W;
		view_hport[0] = PORT_H;
		
		surface_resize(application_surface, PORT_W, PORT_H);
		
		window_set_size(PORT_W, PORT_H);
		window_set_position((display_get_width() - PORT_W) * 0.5, (display_get_height() - PORT_H) * 0.5);
	};
	
	static toggle_fullscreen = function() {
		fullscreen = !fullscreen;
		
		if fullscreen window_enable_borderless_fullscreen(fullscreen);
		window_set_fullscreen(fullscreen);
		if !fullscreen window_enable_borderless_fullscreen(fullscreen);
	};
}