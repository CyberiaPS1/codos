
function uf_player() {
	var input__left = IotaGetInput(BIND_MAIN__LEFT);
	var input__right = IotaGetInput(BIND_MAIN__RIGHT);
	var input__jump = IotaGetInput(BIND_MAIN__JUMP);
	var input__moving = input__right - input__left
	inputs.moving = input__moving;
	inputs.jump = input__jump;
	
	if input__moving != 0
		fsm.trigger("walk");
	if input__jump
		fsm.trigger("jump");
	fsm.trigger("default");
	
	fsm.step();
	anim.step();
	
	grounded = uf_is_grounded();
}


/// STATES

#region Stand

function uf_player_stand_start(context) {
	anim.set("stand");
}

function uf_player_stand_step(context) {
	
	uf_apply_physics();
	move_and_collide(vx, vy, objass_wall);
}

#endregion



#region Walk

function uf_player_walk_start(context) {
	anim.set("walk");
}

function uf_player_walk_step(context) {
	
	face = inputs.moving;
	
	uf_apply_physics();
	uf_apply_move(inputs.moving);
	move_and_collide(vx, vy, objass_wall);
}

#endregion



#region Airborn

function uf_player_airborn_start(context) {
	anim.set("stand");
	
	if inputs.jump {
		vy = -jump_speed * TICKTIME;
		jumps--;
	}
	
	if jumps == jumpsmax
		jumps--;
	
	grounded = false;
}

function uf_player_airborn_step(context) {
	uf_apply_physics();
	uf_apply_move(inputs.moving);
	move_and_collide(vx, vy, objass_wall);
}

function uf_player_airborn_stop(context) {
	if grounded
		jumps = jumpsmax;
}

#endregion