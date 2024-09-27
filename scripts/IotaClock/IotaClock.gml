// Feather disable all

/// Constructor that instantiates an iota clock
/// 
/// @param [identifier]   Unique name for this clock. IOTA_CURRENT_CLOCK will be set to this value when the clock's .Update() method is called. Defaults to <undefined>
/// 
/// 
/// 
/// iota clocks have the following public methods:
/// 
///   .Update()
///     Updates the clock and executes methods. This method returns how many clock ticks were executed
///     A clock will execute enough ticks to match its realtime update frequency
///     This means a clock may execute zero ticks, or sometimes multiple ticks
///   
///   
///   
///   .AddBeginTickMethod(method)
///     Adds a method to be executed at the start of a tick, before normal/end tick methods and before alarms are ticked down
///     The scope of the method passed into this function will persist
///     Only one begin method can be defined per instance/struct
///     Begin methods will *not* be executed if the clock doesn't need to execute any ticks at all
///   
///   .AddTickMethod(method)
///     Adds a method to be executed for each tick after the begin tick method and after alarms are ticked down
///     The scope of the method passed into this function will persist
///     Only one tick method can be defined per instance/struct
///     Tick methods will *not* be executed if the clock doesn't need to execute any ticks at all
///   
///   .AddEndTickMethod(method)
///     Adds a method to be executed at the end of a tick, after all tick methods and alarms
///     The scope of the method passed into this function will persist
///     Only one end method can be defined per instance/struct
///     End methods will *not* be executed if the clock doesn't need to execute any ticks at all
///   
///   .AddTickUserEvents([begin], [normal], [end])
///     Adds three user events to be executed as begin/normal/end tick methods. See above for more details
///     Use <undefined> to indicate that a user event shouldn't be used
///     This function is mutually exclusive with the method setters above and is provided for convenience
///   
///   
///   
///   .VariableInterpolate(inputVariableName, outputVariableName, [scope])
///     Adds a variable to be smoothly interpolated between iota ticks. The interpolated value is passed to the given output variable name
///     Interpolated variables are always updated every time .Update() is called, even if the clock does not need to execute any ticks
///     The variables' scope is typically determined by who calls .VariableInterpolate(), though for structs you may need to specify the optional [scope] argument
///       N.B. Interpolated variables will always be (at most) a frame behind the actual value of the input variable
///            Most of this time this makes no difference but it's not ideal if you're looking for frame-perfect gameplay
///   
///   .VariableInterpolateAngle(inputVariableName, outputVariableName, [scope])
///     As above, but the value is interpolated as an angle measured in degrees. The output value will be an angle from -360 to +360.
///   
///   
///   
///   .DefineInput(inputName, defaultValue)
///     Adds a named input to the clock. This should be used to funnel user input into the clock.
///     Defined inputs should be set using the .SetInput() method (see below) and can be read in
///     a clock tick method using IotaGetInput(). .DefineInput() should be used for "continuous"
///     values such as those returned by keyboard_check() or gamepad_axis_value() or mouse_x.
///   
///   .DefineInputMomentary(inputName, defaultValue)
///     See above for the general purpose for this method. .DefineInputMomentary() additionally
///     marks an input as "momentary" which does two things:
///     
///     1) Momentary input values are reset to their defaults at the end of the first tick per
///        clock update.
///     2) Momentary input values are treated differently when setting values using .SetInput().
///        See below for more information.
///   
///   .SetInput(inputName, value)
///     Set the value of an input defined using one of the two prior methods. For non-momentary
///     "continuous" inputs, .SetInput() will simply set the value of the input as you'd expect.
///     However, if an input has been defined as "momentary" then a value will only be set if it is
///     different to the default value for the input. This means that, once set to a different
///     value, an input cannot be reset to the default. This solves problems with dropped inputs
///     when the application framerate is significantly higher than the clock update frequency.
///   
///   
///   
///   .AddAlarm(milliseconds, method)
///     Adds a method to be executed after the given number of milliseconds have passed for this clock
///     The scope of the method is maintained. If the instance/struct attached to the method is removed, the method will not execute
///     iota alarms respect time dilation and pausing - N.B. Changing a clock's update frequency will cause alarms to desynchronise
///   
///   .AddAlarmTicks(ticks, method)
///     Adds a method to be executed after the given number of ticks have passed for this clock
///     The scope of the method is maintained. If the instance/struct attached to the method is removed, the method will not execute
///     iota alarms respect time dilation and pausing - N.B. Changing a clock's update frequency will cause alarms to desynchronise
///   
///   
///   
///   .SetPause(state)
///     Sets whether the clock is paused
///     A paused clock will execute no methods nor modify any variables
///     
///   .GetPause(state)
///     Returns whether the clock is paused
///     
///   .SetUpdateFrequency(frequency)
///     Sets the update frequency for the clock. This value should generally not be changed once you've set it
///     This value will default to matching your game's target framerate at the time that the clock was instantiated
///     
///   .GetUpdateFrequency()
///     Returns the update frequency for the clock
///   
///   .SetTimeDilation(multiplier)
///     Sets the time dilation multiplier. A value of 1 is no time dilation, 0.5 is half speed, 2.0 is double speed
///     Time dilation values cannot be set lower than 0
///     
///   .GetTimeDilation(state)
///     Returns the time dilation multiplier
///     
///   .GetRemainder()
///     Returns the remainder on the accumulator



function IotaClock(_identifier = undefined) constructor
{
    static _iota = __Iota();
    
    __identifier      = _identifier
    __updateFrequency = game_get_speed(gamespeed_fps);
    __paused          = false;
    __dilation        = 1.0;
    __secondsPerTick  = 1 / (__dilation*__updateFrequency);
    __accumulator     = 0;
    
    __childrenStruct      = {};
    __beginMethodArray    = [];
    __normalMethodArray   = [];
    __endMethodArray      = [];
    __varInterpolateArray = [];
    __alarmArray          = [];
    
    __inputNameArray      = [];
    __inputMomentaryArray = [];
    __inputMomentaryDict  = {};
    __inputDefaultDict    = {};
    __inputValueDict      = {};
    
    #region Update
    
    static Update = function()
    {
        IOTA_CURRENT_CLOCK = __identifier;
        _iota.__currentClock = self;
        
        //Get the clamped delta time value for this GameMaker frame
        //We clamp the bottom end to ensure that games still chug along even if the device is really grinding
        var _delta = min(1/IOTA_MINIMUM_FRAMERATE, delta_time/1000000);
        
        //Start off assuming this clock isn't going to want to process any ticks whatsoever
        IOTA_TICKS_FOR_CLOCK = 0;
        
        //If we're not paused, figure out how many full ticks this clock requires based the accumulator and the clock's framerate
        if (!__paused && (__dilation > 0))
        {
            __accumulator += _delta;
            IOTA_TICKS_FOR_CLOCK = floor(__accumulator/__secondsPerTick);
            __accumulator -= IOTA_TICKS_FOR_CLOCK*__secondsPerTick;
        }
        
        if (IOTA_TICKS_FOR_CLOCK > 0)
        {
            IOTA_SECONDS_PER_TICK = __secondsPerTick;
            IOTA_TICK_INDEX = -1;
            
            //Execute ticks one at a time
            //Note that we're processing all methods for a tick, then move onto the next tick
            //This ensures instances doesn't get out of step with each other
            IOTA_TICK_INDEX = 0;
            repeat(IOTA_TICKS_FOR_CLOCK)
            {
                //Capture interpolated variable state before the final tick
                if (IOTA_TICK_INDEX == IOTA_TICKS_FOR_CLOCK-1) __VariablesInterpolateRefresh();
                
                __execute_methods(__IOTA_CHILD.__BEGIN_METHOD);
                
                var _i = 0;
                repeat(array_length(__alarmArray))
                {
                    if (__alarmArray[_i].__Tick())
                    {
                        array_delete(__alarmArray, _i, 1);
                    }
                    else
                    {
                        ++_i;
                    }
                }
                
                __execute_methods(__IOTA_CHILD.__NORMAL_METHOD);
                __execute_methods(__IOTA_CHILD.__END_METHOD);
                
                //Reset momentary input after the first tick
                if (IOTA_TICK_INDEX == 0)
                {
                    __ResetInputMomentary();
                }
                
                IOTA_TICK_INDEX++;
            }
            
            IOTA_TICK_INDEX = IOTA_TICKS_FOR_CLOCK;
            __ResetInputAll();
        }
        
        //Update our output interpolated variables
        if (!__paused && (__dilation > 0)) __VariablesInterpolateUpdate();
        
        var _ticks = IOTA_TICKS_FOR_CLOCK;
        
        //Make sure to reset these macros so they can't be accessed outside of iota methods
        IOTA_CURRENT_CLOCK    = undefined;
        IOTA_TICKS_FOR_CLOCK  = undefined;
        IOTA_TICK_INDEX       = undefined;
        IOTA_SECONDS_PER_TICK = undefined;
        
        _iota.__currentClock = undefined;
        
        return _ticks;
    }
    
    #endregion
    
    #region Methods Adders
    
    static AddBeginTickMethod = function(_method, _scope = other)
    {
        return __AddMethodGeneric(_method, _scope, __IOTA_CHILD.__BEGIN_METHOD);
    }
    
    static AddTickMethod = function(_method, _scope = other)
    {
        return __AddMethodGeneric(_method, _scope, __IOTA_CHILD.__NORMAL_METHOD);
    }
    
    static AddEndTickMethod = function(_method, _scope = other)
    {
        return __AddMethodGeneric(_method, _scope, __IOTA_CHILD.__END_METHOD);
    }
    
    static AddTickUserEvents = function(_begin = undefined, _normal = undefined, _end = undefined)
    {
        //Scoping is weird
        with(other)
        {
            if (_begin != undefined)
            {
                __iotaBeginUserEvent = _begin;
                other.AddBeginTickMethod(function() { event_user(__iotaBeginUserEvent); });
            }
            
            if (_normal != undefined)
            {
                __iotaTickUserEvent = _normal;
                other.AddTickMethod(function() { event_user(__iotaTickUserEvent); });
            }
            
            if (_end != undefined)
            {
                __iotaEndUserEvent = _end;
                other.AddEndTickMethod(function() { event_user(__iotaEndUserEvent); });
            }
        }
    }
    
    #endregion
    
    #region Inputs
    
    static DefineInput = function(_inputName, _defaultValue)
    {
        if (variable_struct_exists(__inputDefaultDict, _inputName))
        {
            __IotaTrace("Warning! Input name \"", _inputName, "\" already defined");
        }
        else
        {
            array_push(__inputNameArray, _inputName);
            __inputDefaultDict[$ _inputName] = _defaultValue;
        }
    }
    
    static DefineInputMomentary = function(_inputName, _defaultValue)
    {
        if (variable_struct_exists(__inputDefaultDict, _inputName))
        {
            __IotaTrace("Warning! Input name \"", _inputName, "\" already defined");
        }
        else
        {
            array_push(__inputNameArray, _inputName);
            array_push(__inputMomentaryArray, _inputName);
            __inputMomentaryDict[$ _inputName] = true;
            __inputDefaultDict[$ _inputName] = _defaultValue;
        }
    }
    
    static SetInput = function(_inputName, _value)
    {
        if (__inputMomentaryDict[$ _inputName] ?? false)
        {
            //Special logic for momentary inputs - we cache values that are different to the default and don't
            //let this method call reset momentary inputs to their default value
            if (_value != __inputDefaultDict[$ _inputName])
            {
                __inputValueDict[$ _inputName] = _value;
            }
        }
        else
        {
            __inputValueDict[$ _inputName] = _value;
        }
    }
    
    static __GetInput = function(_inputName)
    {
        return __inputValueDict[$ _inputName] ?? __inputDefaultDict[$ _inputName];
    }
    
    static __ResetInputMomentary = function()
    {
        var _nameArray = __inputMomentaryArray;
        var _i = 0;
        repeat(array_length(_nameArray))
        {
            variable_struct_remove(__inputValueDict, _nameArray[_i]);
            ++_i;
        }
    }
    
    static __ResetInputAll = function()
    {
        var _nameArray = __inputNameArray;
        var _i = 0;
        repeat(array_length(_nameArray))
        {
            variable_struct_remove(__inputValueDict, _nameArray[_i]);
            ++_i;
        }
    }
    
    #endregion
    
    #region Variables
    
    static VariableInterpolate = function(_inName, _outName, _scope = other)
    {
        return __VariableInterpolateCommon(_inName, _outName, _scope, false);
    }
    
    static VariableInterpolateAngle = function(_inName, _outName, _scope = other)
    {
        return __VariableInterpolateCommon(_inName, _outName, _scope, true);
    }
    
    static __VariableInterpolateCommon = function(_inName, _outName, _scope, _is_angle)
    {
        var _childData = __GetChildData(_scope);
        
        //Catch weird errors due to scoping
        if (!is_array(_childData))
        {
            __IotaError("Scope could not be determined (data type=", typeof(_scope), ")");
        }
        
        var _array = _childData[__IOTA_CHILD.__VARIABLES_INTERPOLATE];
        
        if (_array == undefined)
        {
            _array = [];
            _childData[@ __IOTA_CHILD.__VARIABLES_INTERPOLATE] = _array;
            array_push(__varInterpolateArray, _childData);
        }
        
        var _i = 0;
        repeat(array_length(_array) div __IOTA_INTERPOLATED_VARIABLE.__SIZE)
        {
            if (_array[_i] == _inName)
            {
                //This variable already exists
                return undefined;
            }
            
            _i += __IOTA_INTERPOLATED_VARIABLE.__SIZE;
        }
        
        array_push(_array, _inName, _outName, variable_instance_get(_scope, _inName), _is_angle);
        variable_instance_set(_scope, _outName, variable_instance_get(_scope, _inName));
    }
    
    static __VariableSkipInterpolation = function(_outName, _scope)
    {
        var _childData = __GetChildData(_scope);
        
        var _variables = _childData[__IOTA_CHILD.__VARIABLES_INTERPOLATE];
        var _j = 0;
        repeat(array_length(_variables) div __IOTA_INTERPOLATED_VARIABLE.__SIZE)
        {
            if (_variables[@ _j + __IOTA_INTERPOLATED_VARIABLE.__OUT_NAME] == _outName)
            {
                _variables[@ _j + __IOTA_INTERPOLATED_VARIABLE.__PREV_VALUE] = variable_instance_get(_scope, _variables[_j + __IOTA_INTERPOLATED_VARIABLE.__IN_NAME]);
            }
            
            _j += __IOTA_INTERPOLATED_VARIABLE.__SIZE;
        }
    }
    
    #endregion
    
    #region Alarms
    
    static AddAlarm = function(_time, _method)
    {
        return new __IotaClassAlarm(self, (_time / 1000) * GetUpdateFrequency(), _method);
    }
    
    static AddAlarmTicks = function(_ticks, _method)
    {
        return new __IotaClassAlarm(self, _ticks, _method);
    }
    
    #endregion
    
    #region Pause / Target Framerate / Time Dilation
    
    static SetPause = function(_state)
    {
        __paused = _state;
    }
    
    static GetPause = function()
    {
        return __paused;
    }
    
    static SetUpdateFrequency = function(_frequency)
    {
        __updateFrequency = _frequency;
        __secondsPerTick = 1 / (__dilation*__updateFrequency);
    }
    
    static GetUpdateFrequency = function()
    {
        return __updateFrequency;
    }
    
    static SetTimeDilation = function(_multiplier)
    {
        __dilation = max(0, _multiplier);
        __secondsPerTick = 1 / (__dilation*__updateFrequency);
    }
    
    static GetTimeDilation = function()
    {
        return __dilation;
    }
    
    static GetRemainder = function()
    {
        return __dilation*__updateFrequency*__accumulator;
    }
    
    #endregion
    
    #region (Private Methods)
    
    static __execute_methods = function(_method_type)
    {
        switch(_method_type)
        {
            case __IOTA_CHILD.__BEGIN_METHOD: var _array = __beginMethodArray; break;
            case __IOTA_CHILD.__NORMAL_METHOD: var _array = __normalMethodArray; break;
            case __IOTA_CHILD.__END_METHOD:   var _array = __endMethodArray;   break;
        }
        
        var _i = 0;
        repeat(array_length(_array))
        {
            var _childData = _array[_i];
            
            //If another process found that this child no longer exists, remove it from this array too
            if (_childData[__IOTA_CHILD.__DEAD])
            {
                array_delete(_array, _i, 1);
                continue;
            }
            
            var _scope = _childData[__IOTA_CHILD.__SCOPE];
            switch(__IotaScopeExists(_scope, _childData[__IOTA_CHILD.__IOTA_ID]))
            {
                case 1: //Alive instance
                    with(_scope) _childData[_method_type]();
                break;
                
                case 2: //Alive struct
                    with(_scope.ref) _childData[_method_type]();
                break;
                
                case -1: //Dead instance
                case -2: //Dead struct
				case -3: //Instance has different child ID
                    array_delete(_array, _i, 1);
                    __MarkChildAsDead(_childData);
                    continue;
                break;
                
                case 0: //Deactivated instance
                break;
            }
            
            ++_i;
        }
    }
    
    static __MarkChildAsDead = function(_childData)
    {
        variable_struct_remove(__childrenStruct, _childData[__IOTA_CHILD.__IOTA_ID]);
        _childData[@ __IOTA_CHILD.__DEAD] = true;
    }
    
    static __AddMethodGeneric = function(_method, _scope, _method_type)
    {
        if (is_numeric(_method))
        {
            //Might be a script index
            if (script_exists(_method))
            {
                _method = method(other, _method);
            }
            else
            {
                __IotaError("Could not find script index ", _method);
            }
        }
        else if (!is_method(_method))
        {
            __IotaError("Method was an incorrect data type (", typeof(_method), ")");
        }
        
        //var _scope = method_get_self(_method);
        if (_scope == undefined) _scope = other;
        
        switch(_method_type)
        {
            case __IOTA_CHILD.__BEGIN_METHOD: var _array = __beginMethodArray; break;
            case __IOTA_CHILD.__NORMAL_METHOD: var _array = __normalMethodArray; break;
            case __IOTA_CHILD.__END_METHOD:   var _array = __endMethodArray;   break;
        }
        
        var _childData = __GetChildData(_scope);
        
        //Catch weird errors due to scoping
        if (!is_array(_childData))
        {
            __IotaError("iota:\nScope could not be determined (data type=", typeof(_scope), ")");
        }
        
        //If we haven't seen this method type before for this child, add the child to the relevant array
        if (_childData[_method_type] == undefined) array_push(_array, _childData);
        
        //Set the relevant element in the data packet
        //We strip the scope off the method so we don't accidentally keep structs alive
        _childData[@ _method_type] = method(undefined, _method);
    }
    
    static __GetChildData = function(_scope)
    {
        var _isInstance = false;
        var _isStruct   = false;
        var _id         = undefined;
        
        if (is_numeric(_scope))
        {
            if (_scope < 100000)
            {
                __IotaError("Method scope must be an instance or a struct, object indexes are not permitted");
            }
        }
        else if (!is_struct(_scope) && !instance_exists(_scope))
        {
            __IotaError("Method scope must be an instance or a struct, found scope's data type was ", typeof(_scope));
        }
        
        var _childID   = __IotaEnsureChildID(_scope);
        var _childData = __childrenStruct[$ _childID];
		
        //If this scope didn't have any data for this clock, create some
        if (_childData == undefined)
        {
            //If the scope is a real number then presume it's an instance ID
            if (is_numeric(_scope))
            {
                //We found a valid instance ID so let's set some variables based on that
                //Changing scope here works around some bugs in GameMaker that I don't think exist any more?
                with(_scope)
                {
                    _scope = self;
                    _isInstance = true;
                    _id = id;
                    break;
                }
            }
            else
            {
                //Sooooometimes we might get given a struct which is actually an instance
                //Despite being able to read struct variable, it doesn't report as a struct... which is weird
                //Anyway, this check works around that!
                var _id = variable_instance_get(_scope, "id");
                if (is_numeric(_id) && !is_struct(_scope))
                {
                    if (instance_exists(_id))
                    {
                        _isInstance = true;
                    }
                    else
                    {
                        //Do a deactivation check here too, why not
                        if (IOTA_CHECK_FOR_DEACTIVATION)
                        {
                            instance_activate_object(_id);
                            if (instance_exists(_id))
                            {
                                _isInstance = true;
                                instance_deactivate_object(_id);
                            }
                        }
                    }
                }
                else if (is_struct(_scope))
                {
                    _isStruct = true;
                }
            }
            
            //Give this scope a unique iota ID
            //This'll save us some pain later if we need to add a different sort of method
            variable_instance_set(_scope, IOTA_ID_VARIABLE_NAME, _childID);
            
            //Create a new data packet and set it up
            var _childData = array_create(__IOTA_CHILD.__SIZE, undefined);
            _childData[@ __IOTA_CHILD.__IOTA_ID] = _childID;
            _childData[@ __IOTA_CHILD.__SCOPE  ] = (_isInstance? _id : weak_ref_create(_scope));
            _childData[@ __IOTA_CHILD.__DEAD   ] = false;
        
            //Then slot this data packet into the clock's data struct + array
            __childrenStruct[$ _childID] = _childData;
        }
        
        return _childData;
    }
    
    static __VariablesInterpolateRefresh = function()
    {
        var _array = __varInterpolateArray;
        
        var _i = 0;
        repeat(array_length(_array))
        {
            var _childData = _array[_i];
            
            //If another process found that this child no longer exists, remove it from this array too
            if (_childData[__IOTA_CHILD.__DEAD])
            {
                array_delete(_array, _i, 1);
                continue;
            }
            
            var _scope = _childData[__IOTA_CHILD.__SCOPE];
            switch(__IotaScopeExists(_scope, _childData[__IOTA_CHILD.__IOTA_ID]))
            {
                case 1: //Alive instance
                case 2: //Alive struct
                    //If our scope isn't a real then it's a struct, so jump into the struct itself
                    if (!is_numeric(_scope)) _scope = _scope.ref;
                    
                    var _variables = _childData[__IOTA_CHILD.__VARIABLES_INTERPOLATE];
                    var _j = 0;
                    repeat(array_length(_variables) div __IOTA_INTERPOLATED_VARIABLE.__SIZE)
                    {
                        _variables[@ _j + __IOTA_INTERPOLATED_VARIABLE.__PREV_VALUE] = variable_instance_get(_scope, _variables[_j + __IOTA_INTERPOLATED_VARIABLE.__IN_NAME]);
                        _j += __IOTA_INTERPOLATED_VARIABLE.__SIZE;
                    }
                break;
                
                case -1: //Dead instance
                case -2: //Dead struct
                case -3: //Instance has different child ID
                    array_delete(_array, _i, 1);
                    __MarkChildAsDead(_childData);
                    continue;
                break;
                
                case 0: //Deactivated instance
                break;
            }
            
            ++_i;
        }
    }
    
    static __VariablesInterpolateUpdate = function()
    {
        var _remainder = GetRemainder();
        var _array = __varInterpolateArray;
        
        var _i = 0;
        repeat(array_length(_array))
        {
            var _childData = _array[_i];
            
            //If another process found that this child no longer exists, remove it from this array too
            if (_childData[__IOTA_CHILD.__DEAD])
            {
                array_delete(_array, _i, 1);
                continue;
            }
            
            var _scope = _childData[__IOTA_CHILD.__SCOPE];
            switch(__IotaScopeExists(_scope, _childData[__IOTA_CHILD.__IOTA_ID]))
            {
                case 1: //Alive instance
                case 2: //Alive struct
                    //If our scope isn't a real then it's a struct, so jump into the struct itself
                    if (!is_numeric(_scope)) _scope = _scope.ref;
                    
                    var _variables = _childData[__IOTA_CHILD.__VARIABLES_INTERPOLATE];
                    var _j = 0;
                    repeat(array_length(_variables) div __IOTA_INTERPOLATED_VARIABLE.__SIZE)
                    {
                        if (_variables[_j + __IOTA_INTERPOLATED_VARIABLE.__IS_ANGLE])
                        {
                            var _oldValue = _variables[_j + __IOTA_INTERPOLATED_VARIABLE.__PREV_VALUE];
                            var _newValue = _oldValue + _remainder*angle_difference(variable_instance_get(_scope, _variables[_j + __IOTA_INTERPOLATED_VARIABLE.__IN_NAME]), _oldValue);
                        }
                        else
                        {
                            var _newValue = lerp(_variables[_j + __IOTA_INTERPOLATED_VARIABLE.__PREV_VALUE], variable_instance_get(_scope, _variables[_j + __IOTA_INTERPOLATED_VARIABLE.__IN_NAME]), _remainder);
                        }
                        
                        variable_instance_set(_scope, _variables[_j + __IOTA_INTERPOLATED_VARIABLE.__OUT_NAME], _newValue);
                        
                        _j += __IOTA_INTERPOLATED_VARIABLE.__SIZE;
                    }
                break;
                
                case -1: //Dead instance
                case -2: //Dead struct
                case -3: //Instance has different child ID
                    array_delete(_array, _i, 1);
                    __MarkChildAsDead(_childData);
                    continue;
                break;
                
                case 0: //Deactivated instance
                break;
            }
            
            ++_i;
        }
    }
    
    #endregion
}
