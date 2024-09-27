// Feather disable all

//This script contains the default profiles, and hence the default bindings and verbs, for your game
//
//  Please edit this macro to meet the needs of your game!
//
//The struct return by this script contains the names of each default profile.
//Default profiles then contain the names of verbs. Each verb should be given a binding that is
//appropriate for the profile. You can create bindings by calling one of the input_binding_*()
//functions, such as input_binding_key() for keyboard keys and input_binding_mouse() for
//mouse buttons

function __input_config_verbs()
{
    return {
        keyboard_and_mouse:
        {
            BIND_MAIN__UP:    [input_binding_key(vk_up),    input_binding_key("W")],
            BIND_MAIN__DOWN:  [input_binding_key(vk_down),  input_binding_key("S")],
            BIND_MAIN__LEFT:  [input_binding_key(vk_left),  input_binding_key("A")],
            BIND_MAIN__RIGHT: [input_binding_key(vk_right), input_binding_key("D")],
			
			BIND_MAIN__JUMP: [input_binding_key(vk_space)],
            
            BIND_MAIN__ACTION:  [input_binding_key(vk_space), input_binding_mouse_button(mb_left)],
			
			BIND_MAIN__ACTION2: [input_binding_key(vk_backspace), input_binding_mouse_button(mb_right)],
        }
    };
}