extends Camera2D
class_name TouchCamera2D

@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.5

var _touches: Dictionary = {}
var _state: int = 0 # 0: IDLE, 1: PAN, 2: PINCH

# Pan state
var _pan_start_pos: Vector2
var _cam_start_pos: Vector2

# Pinch state
var _pinch_start_dist: float
var _pinch_start_zoom: Vector2
var _pinch_start_center_screen: Vector2
var _pinch_start_center_world: Vector2

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_apply_zoom_at_mouse(clamp(zoom.x * 1.1, min_zoom, max_zoom), event.position)
			get_viewport().set_input_as_handled()
			return
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_apply_zoom_at_mouse(clamp(zoom.x * 0.9, min_zoom, max_zoom), event.position)
			get_viewport().set_input_as_handled()
			return

	# Suporte simultâneo para Touch nativo e Mouse
	var is_touch_press = false
	var is_touch_release = false
	var touch_pos = Vector2.ZERO
	var touch_idx = 0
	
	if event is InputEventScreenTouch:
		is_touch_press = event.pressed
		is_touch_release = not event.pressed
		touch_pos = event.position
		touch_idx = event.index
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if ProjectSettings.get_setting("input_devices/pointing/emulate_touch_from_mouse"):
			return
		is_touch_press = event.pressed
		is_touch_release = not event.pressed
		touch_pos = event.position
		touch_idx = -1 # Mouse is always index -1 in our logic
		
	if is_touch_press or is_touch_release:
		if is_touch_press:
			_touches[touch_idx] = touch_pos
		else:
			_touches.erase(touch_idx)
			
		_update_state()
		get_viewport().set_input_as_handled()
		return
		
	var is_drag = false
	if event is InputEventScreenDrag:
		is_drag = true
		touch_pos = event.position
		touch_idx = event.index
	elif event is InputEventMouseMotion and _touches.has(-1):
		is_drag = true
		touch_pos = event.position
		touch_idx = -1
		
	if is_drag and _touches.has(touch_idx):
		_touches[touch_idx] = touch_pos
		if _state == 1: # PAN
			_process_pan()
			get_viewport().set_input_as_handled()
		elif _state == 2: # PINCH
			_process_pinch()
			get_viewport().set_input_as_handled()

var is_brush_mode: bool = false

func _update_state() -> void:
	var count: int = _touches.size()
	if count == 0:
		_state = 0 # IDLE
	elif count == 1:
		if is_brush_mode:
			_state = 0 # IDLE (Ignora Pan para permitir o pincel pintar o mapa)
		else:
			_state = 1 # PAN
			var pts: Array = _touches.values()
			_pan_start_pos = pts[0]
			_cam_start_pos = global_position
	elif count >= 2:
		_state = 2 # PINCH
		var pts: Array = _touches.values()
		_pinch_start_dist = pts[0].distance_to(pts[1])
		_pinch_start_zoom = zoom
		_pinch_start_center_screen = (pts[0] + pts[1]) / 2.0
		_pinch_start_center_world = get_screen_center_position() + (_pinch_start_center_screen - get_viewport_rect().size / 2.0) / zoom

func _process_pan() -> void:
	var pts: Array = _touches.values()
	var drag_diff: Vector2 = (pts[0] - _pan_start_pos) / zoom
	global_position = _cam_start_pos - drag_diff

func _process_pinch() -> void:
	var pts: Array = _touches.values()
	var current_dist: float = pts[0].distance_to(pts[1])
	if _pinch_start_dist < 1.0:
		return
		
	var ratio: float = current_dist / _pinch_start_dist
	var new_zoom: float = clamp(_pinch_start_zoom.x * ratio, min_zoom, max_zoom)
	
	zoom = Vector2(new_zoom, new_zoom)
	
	var current_center_screen: Vector2 = (pts[0] + pts[1]) / 2.0
	var current_center_world: Vector2 = get_screen_center_position() + (current_center_screen - get_viewport_rect().size / 2.0) / zoom
	
	global_position -= (current_center_world - _pinch_start_center_world)

func _apply_zoom_at_mouse(new_zoom: float, mouse_pos: Vector2) -> void:
	var old_zoom = zoom
	zoom = Vector2(new_zoom, new_zoom)
	var screen_center = get_viewport_rect().size / 2.0
	var mouse_world_before = global_position + (mouse_pos - screen_center) / old_zoom
	var mouse_world_after = global_position + (mouse_pos - screen_center) / zoom
	global_position -= (mouse_world_after - mouse_world_before)
