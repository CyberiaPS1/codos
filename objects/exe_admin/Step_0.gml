


//switch global.runmode {
	
	//case RUNMODE.GAME:
		var clock = global.clocks[CLOCK.GAME];
		
		clock.SetInput(BIND_MAIN__UP, input_check(BIND_MAIN__UP));
		clock.SetInput(BIND_MAIN__DOWN, input_check(BIND_MAIN__DOWN));
		clock.SetInput(BIND_MAIN__LEFT, input_check(BIND_MAIN__LEFT));
		clock.SetInput(BIND_MAIN__RIGHT, input_check(BIND_MAIN__RIGHT));
		clock.SetInput(BIND_MAIN__JUMP, input_check_pressed(BIND_MAIN__JUMP));
		
		
		clock.SetInput(BIND_MAIN__ACTION2, input_check_pressed(BIND_MAIN__ACTION2));
		
		clock.SetInput(BIND_MAIN__ACTION_PRESS, input_check_pressed(BIND_MAIN__ACTION));
		clock.SetInput(BIND_MAIN__ACTION_RELEASE, input_check_pressed(BIND_MAIN__ACTION));
		
		
		
		clock.Update();
	//break;
//}



/// DEV CODE
#region Debug Inputs

if keyboard_check_pressed(vk_f1)
	global.debug = !global.debug;

if keyboard_check_pressed(vk_f2)
	game_restart();

if keyboard_check_pressed(vk_f3)
	display.toggle_fullscreen();

if keyboard_check_pressed(vk_f5)
	game_end();

#endregion

