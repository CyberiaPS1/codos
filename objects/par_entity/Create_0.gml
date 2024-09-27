
show_debug_message("PLAYER ID: "+string(id));
//width = sprite_get_width(sprite_index);
//height = sprite_get_height(sprite_index);

__acceleration = 4000;
__gravity = 2000;
__friction = 2500;
max_speed = 300;
vx = 0;
vy = 0;

face = 1;
mx = 0;
my = 0;


anim = new AnimationMgr();
anim.set("stand");