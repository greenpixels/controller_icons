extends Node 

class DebouncedCall:
	var callback: Callable
	var wait_time: float
	var timer: Timer
	var is_leading: bool
	var next_frame: bool
	var scheduled: bool
	var last_args: Array
	var key : String
	var omit_on_invalid: bool # To get around "Lambda capture at index 0 was freed. Passed "null" instead
	
	func _init(cb: Callable, delay: float, leading: bool, on_next_frame: bool, _key: String):
		key = _key
		callback = cb
		wait_time = delay
		is_leading = leading
		next_frame = on_next_frame
		timer = Timer.new()
		timer.one_shot = true
		timer.timeout.connect(_on_timeout)
		
	func _on_timeout():
		if not is_leading:
			Debounce._trigger_callback(self)
		scheduled = false

var _debounced_calls: Dictionary[String, DebouncedCall] = {}

func debounce(key: String, callback: Callable, args = [], wait_time: float = 0.1, is_leading: bool = false, on_next_frame: bool = false) -> void:
	if not _debounced_calls.has(key):
		var debounced = DebouncedCall.new(callback, wait_time, is_leading, on_next_frame, key)
		add_child(debounced.timer)
		_debounced_calls[key] = debounced
	
	var call: DebouncedCall = _debounced_calls[key]
	call.last_args = args
	
	if call.next_frame:
		if not call.scheduled:
			call.scheduled = true
			if Engine.is_in_physics_frame():
				call_deferred("_execute_next_physics_frame", key)
			else:
				call_deferred("_execute_next_frame", key)
		return
		
	if not call.scheduled and call.is_leading:
		_trigger_callback(call)
		
	call.scheduled = true
	call.timer.start(call.wait_time)

func _execute_next_frame(key: String) -> void:
	if not _debounced_calls.has(key): return
	var call: DebouncedCall = _debounced_calls[key]
	_trigger_callback(call)
	call.scheduled = false
	clear(key)

func _trigger_callback(call : DebouncedCall):
	for argument in call.last_args:
		if not is_instance_valid(argument):
			argument = null
	call.callback.callv(call.last_args)

func _execute_next_physics_frame(key: String) -> void:
	await get_tree().physics_frame
	if not _debounced_calls.has(key): return
	var call: DebouncedCall = _debounced_calls[key]
	_trigger_callback(call)
	call.scheduled = false
	clear(key)

func clear(key: String) -> void:
	if _debounced_calls.has(key):
		_debounced_calls[key].timer.queue_free()
		_debounced_calls.erase(key)
