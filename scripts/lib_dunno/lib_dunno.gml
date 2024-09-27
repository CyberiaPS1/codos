

function gf_game_create() {
	var clock = global.clocks[CLOCK.GAME];
	clock.AddTickMethod(proc_game);
	
	client = new Client();
}

