extends Node2D
class_name Token

@export var token_id: String
@export var owner_peer_id: int = 1

var grid_position: Vector2i
var is_dragging: bool = false
var drag_touch_index: int = -1

var _grid_manager: GridManager 

func setup(id: String, peer_id: int, start_cell: Vector2i, grid: GridManager) -> void:
	token_id = id
	owner_peer_id = peer_id
	_grid_manager = grid
	
	grid_position = start_cell
	if _grid_manager:
		position = _grid_manager.grid_to_world(start_cell)
		# Se a gente é o dono, vamos pintar de azul, se não for de vermelho. (UX visual)
		var is_mine = (owner_peer_id == multiplayer.get_unique_id() or multiplayer.get_unique_id() == 1)
		$Control.self_modulate = Color(0.2, 0.6, 1.0) if is_mine else Color(1.0, 0.3, 0.3)
		$Control/Label.text = id

func _on_control_gui_input(event: InputEvent) -> void:
	var is_touch_press = false
	var is_touch_release = false
	var touch_idx = 0
	
	if event is InputEventScreenTouch:
		is_touch_press = event.pressed
		is_touch_release = not event.pressed
		touch_idx = event.index
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_touch_press = event.pressed
		is_touch_release = not event.pressed
		touch_idx = -1
		
	if is_touch_press and not is_dragging:
		is_dragging = true
		drag_touch_index = touch_idx
		get_viewport().set_input_as_handled()
		z_index = 10
		# Feedback visual de selecionado
		var tween = create_tween()
		tween.tween_property($Control, "scale", Vector2(1.1, 1.1), 0.1)
		return
		
	if is_touch_release and is_dragging and drag_touch_index == touch_idx:
		_end_drag()
		get_viewport().set_input_as_handled()
		return
		
	var is_drag = false
	if event is InputEventScreenDrag:
		is_drag = true
		touch_idx = event.index
	elif event is InputEventMouseMotion and is_dragging:
		is_drag = true
		touch_idx = -1
		
	if is_drag and is_dragging and touch_idx == drag_touch_index:
		position += event.relative * $Control.scale
		get_viewport().set_input_as_handled()

func _end_drag() -> void:
	is_dragging = false
	drag_touch_index = -1
	z_index = 0
	
	var tween = create_tween()
	tween.tween_property($Control, "scale", Vector2(1.0, 1.0), 0.1)
	
	if _grid_manager:
		var target_cell = _grid_manager.world_to_grid(position)
		if not _grid_manager.is_cell_valid(target_cell):
			target_cell = grid_position
			
		# Feedback Otimista
		var target_pos = _grid_manager.grid_to_world(target_cell)
		var move_tween = create_tween()
		move_tween.tween_property(self, "position", target_pos, 0.15).set_trans(Tween.TRANS_SINE)
		
		if multiplayer.is_server():
			request_move(target_cell)
		else:
			rpc_id(1, "request_move", target_cell)

@rpc("any_peer", "call_remote", "reliable")
func request_move(target_cell: Vector2i) -> void:
	if not multiplayer.is_server():
		return
		
	var requester_id = multiplayer.get_remote_sender_id()
	if requester_id == 0:
		requester_id = 1
		
	if not _grid_manager.is_cell_valid(target_cell):
		rpc_id(requester_id, "broadcast_move", grid_position)
		return
		
	if get_parent() and get_parent().get_parent() and "room_state" in get_parent().get_parent():
		get_parent().get_parent().room_state["tokens"][token_id]["x"] = target_cell.x
		get_parent().get_parent().room_state["tokens"][token_id]["y"] = target_cell.y
	
	rpc("broadcast_move", target_cell)
	if requester_id != 1:
		broadcast_move(target_cell)

@rpc("authority", "call_remote", "reliable")
func broadcast_move(target_cell: Vector2i) -> void:
	grid_position = target_cell
	var target_pos = _grid_manager.grid_to_world(grid_position)
	var move_tween = create_tween()
	move_tween.tween_property(self, "position", target_pos, 0.15).set_trans(Tween.TRANS_SINE)
