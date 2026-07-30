class_name CallableState

var normal: Callable
var enter: Callable
var leave: Callable

func _init(p_normal: Callable, p_enter: Callable, p_leave: Callable):
	normal = p_normal
	enter = p_enter
	leave = p_leave
