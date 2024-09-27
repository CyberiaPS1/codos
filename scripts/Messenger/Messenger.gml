
function Messenger() constructor {
	
	networks = {};
	users = {};
	
	static broadcast = function(user, network, msgId, msgData) {
		if !variable_struct_exists(networks, network) {
			show_debug_message("[Messenger.broadcast()] Messege failed to broadcast. Network does not exist.");
			return;
		}
		
		if !is_undefined(user) user = __get_id(user);
		var _network = networks[$ network];
		var i = 0; repeat array_length(_network) {
			var _user = _network[i];
			if _user == user continue;
			with _user messenger_consume(user, msgId, msgData);
			i++;
		}
	};
	
	
	
	static subscribe = function(user, network) {
		user = __get_id(user);
		if !variable_struct_exists(users, user)
			users[$ user] = [];
		array_push(users[$ user], network);
		
		if !variable_struct_exists(networks, network)
			networks[$ network] = [];
		array_push(networks[$ network], user);
	};
	
	static unsubscribe = function(user, network = undefined) {
		user = __get_id(user);
		if !variable_struct_exists(users, user)
			return;
			
		if !variable_struct_exists(networks, network)
			return;
		
		
		var _user = users[$ user];
		if !is_undefined(network) {
			var i = 0; repeat(array_length(_user)) {
				var element = _user[i];
				if element == network {
					array_delete(_user, i, 1);
					break;
				}
				i++;
		} }
		
		
		if is_undefined(network) {
			var i = 0; repeat(array_length(_user)) {
				var _network = networks[$ _user[i]];
				var index = array_get_index(_network, user);
				if index > -1 array_delete(_network, index, 1);
				i++;
			}
		} else {
			var _network = networks[$ network];
			var i = 0; repeat(array_length(_network)) {
				var element = _network[i];
				if element == user {
					array_delete(_network, i, 1);
					break;
				}
				i++;
		} }
		
		
		if is_undefined(network) {
			var i = 0; repeat(array_length(_user)) {
				var _network = networks[$ _user[i]];
				if array_length(_network) == 0
					variable_struct_remove(networks, _user[i]);
				i++;
			}
			
			variable_struct_remove(users, user);
			
		} else {
			if array_length(_user) == 0
				variable_struct_remove(users, user);
				
			if array_length(_network) == 0
				variable_struct_remove(networks, network);
		}
	};


	
	static __get_id = function(user) {
		return is_struct(user) ? weak_ref_create(user) : user.id;
	};
}





function broadcast(user, network, msgId, msgData) {
	global.messenger.broadcast(user, network, msgId, msgData);
}