
show_debug_message("ADMIN ID: "+string(id));

global.admin = self;
//randomize();

/// CONFIG
global.debug = true;
game_set_speed(999, gamespeed_fps);


/// SYSTEM
global.runmode = RUNMODE.MAINMENU;
//gamestate_set(GAMESTATE.INIT, GAMESTATE_INIT.NONE);


/// DISPLAY
display = new Display();
doodle = new Doodle();


/// CLOCKS
/// DEV CODE
global.clocks = [];
var clocks = global.clocks;
array_push(clocks, new IotaClock("Menu"));
array_push(clocks, new IotaClock("Game"));
global.inputs = {};

/*
var clock = clocks[CLOCK.MENU];
clock.SetUpdateFrequency(TICKRATE);

clock.DefineInputMomentary(BIND_MAIN__MOUSEACTIVE, false);
clock.DefineInputMomentary(BIND_MAIN__ACTION_PRESS, false);
clock.DefineInputMomentary(BIND_MAIN__ACTION_RELEASE, false);
global.inputs[$ "menu_action_hold"] = false;
global.inputs[$ "menu_action_hold_time"] = 0;
*/


#region CLOCK - GAME
var clock = clocks[CLOCK.GAME];
clock.SetUpdateFrequency(TICKRATE);

clock.DefineInput(BIND_MAIN__UP, false);
clock.DefineInput(BIND_MAIN__DOWN, false);
clock.DefineInput(BIND_MAIN__LEFT, false);
clock.DefineInput(BIND_MAIN__RIGHT, false);
clock.DefineInputMomentary(BIND_MAIN__JUMP, false);

clock.DefineInputMomentary(BIND_MAIN__MOUSEACTIVE, false);
clock.DefineInputMomentary(BIND_MAIN__ACTION_PRESS, false);
clock.DefineInputMomentary(BIND_MAIN__ACTION_RELEASE, false);
global.inputs[$ "game_action_hold"] = false;
global.inputs[$ "game_action_hold_time"] = 0;
clock.DefineInput("test", 0);
#endregion





/// GAME DATA
client = undefined;

global.animationLibrary = new AnimationLibrary();
global.messenger = new Messenger();

/// Game Variables



/// INPUT
input_source_set(INPUT_MOUSE, 0, INPUT_HOTSWAP_AUTO_PROFILE);


initialized = false;