
function uf_apply_move(dir) {
	if dir > 0
		vx = max(min(vx + (__acceleration * TICKTIME * TICKTIME), max_speed * TICKTIME), -max_speed * TICKTIME);
	
	else if dir < 0
		vx = min(max(vx - (__acceleration * TICKTIME * TICKTIME), -max_speed * TICKTIME), max_speed * TICKTIME);
	
	else if dir == 0 and abs(vx) < 0.01
		vx = 0;
}

function uf_apply_physics() {
	/// vx
	if vx > 0
		vx = max(vx - (__friction * TICKTIME * TICKTIME), 0);
	
	else if vx < 0
		vx = min(vx + (__friction * TICKTIME * TICKTIME), 0);
	
	/// vy
	if grounded
		vy = max(vy - (__gravity * 4 * TICKTIME * TICKTIME), 0);
	
	else {
		if place_meeting(x, y - 1, objass_wall)
			vy = min(vy + (__gravity * 4 * TICKTIME * TICKTIME), max_speed * 2 * TICKTIME);
		else
			vy = min(vy + (__gravity * TICKTIME * TICKTIME), max_speed * 2 * TICKTIME);
	}
}

function uf_is_grounded() {
	return place_meeting(x, y + 1, objass_wall);
}