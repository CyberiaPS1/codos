
event_inherited();

global.clocks[CLOCK.GAME].AddTickMethod(uf_player);

anim = new AnimationMgr();
anim.set("stand");

/*
animName = undefined;
anims = {
	"stand"		: new SpriteData(0, 0, 1, 1, 0),
	"walk"		: new SpriteData(0, 2, 0, 8, 4)
};
*/

jumpsmax = 3;
jumps = jumpsmax;
jump_speed = max_speed * 2;
grounded = uf_is_grounded();

inputs = {};
fsm = new StateMachine();
fsm
	.define_state("stand", {
		start : uf_player_stand_start,
		step  : uf_player_stand_step
	})
	.define_state("walk", {
		start : uf_player_walk_start,
		step  : uf_player_walk_step
	})
	/*.define_state("jump", {
		start : uf_player_jump_start,
		step  : uf_player_jump_step
	})*/
	.define_state("airborn", {
		start : uf_player_airborn_start,
		step  : uf_player_airborn_step,
		stop  : uf_player_airborn_stop
	})
	
	.define_trigger("walk", "stand", "walk")
	.define_trigger("jump", ["stand", "walk", "airborn"], "airborn", function() {
		return jumps > 0; })
	.define_trigger("default", "walk", "stand", function() {
		return inputs.moving == 0; })
	.define_trigger("default", ["stand", "walk"], "airborn", function() {
		return !grounded; })
	.define_trigger("default", "airborn", "stand", function() {
		return grounded and !inputs.moving; })
	.define_trigger("default", "airborn", "walk", function() {
		return grounded and inputs.moving; })
	
	.start("stand");
