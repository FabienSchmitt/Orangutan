class_name CallableStateMachine

var state_dictionary: Dictionary[String, CallableState] = {}
var current_state: String

func add_state(
	name: String,
	normal_state_callable: Callable,
	enter_state_callable: Callable,
	leave_state_callable: Callable
):
	state_dictionary[name] = \
		CallableState.new(normal_state_callable, enter_state_callable, leave_state_callable)

func set_initial_state(state_name: String):
	if state_dictionary.has(state_name):
		_set_state(state_name)
	else:
		push_warning("No state with name " + state_name)


func update(delta: float):
	if current_state != "":  
		state_dictionary[current_state].normal.bind(delta).call()


func change_state(state_name: String):
	print(current_state + " -> " + state_name)
	if state_dictionary.has(state_name):
		_set_state.call_deferred(state_name)
	else:
		push_warning("No state with name " + state_name)


func _set_state(state_name: String):
	if current_state:
		var leave_callable = state_dictionary[current_state].leave
		if leave_callable.is_valid():
			leave_callable.call()
	
	current_state = state_name
	var enter_callable = state_dictionary[current_state].enter
	if enter_callable.is_valid():
		enter_callable.call() 