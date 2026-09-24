extends Node2D
class_name GridManager

@export var map_size: Vector2i = Vector2i(20, 20)

@onready var ground_layer: TileMapLayer = $GroundLayer
@onready var objects_layer: TileMapLayer = $ObjectsLayer
@onready var effects_layer: TileMapLayer = $EffectsLayer
@onready var grid_layer: Node2D = $GridLayer

# Dicionário para manter o estado lógico do mapa (célula -> asset_id)
var _grid_data: Dictionary = {}

var is_brush_mode: bool = false
var is_fill_mode: bool = false
var current_brush_asset: String = ""
var current_layer_focus: String = "Ground"

func _ready() -> void:
	y_sort_enabled = true
	objects_layer.y_sort_enabled = true
	
	if grid_layer:
		grid_layer.map_size = map_size
		grid_layer.queue_redraw()
	_init_grid()

func _init_grid() -> void:
	for x in range(map_size.x):
		for y in range(map_size.y):
			var cell := Vector2i(x, y)
			_grid_data[cell] = {"Ground": "", "Objects": "", "Effects": ""}

func get_map_data() -> Dictionary:
	return _grid_data

func load_map_data(data: Dictionary) -> void:
	for cell in data:
		_grid_data[cell] = data[cell]
		for layer in _grid_data[cell]:
			var asset_id = _grid_data[cell][layer]
			if asset_id != "":
				var asset = TilesetManager.get_asset(asset_id)
				if asset:
					_paint_asset_on_layer(cell, asset)

func _paint_asset_on_layer(cell: Vector2i, asset: AssetData) -> void:
	var layer_node: TileMapLayer = null
	
	match asset.default_layer:
		"Ground":
			layer_node = ground_layer
		"Objects":
			layer_node = objects_layer
		"Effects":
			layer_node = effects_layer
			
	if layer_node:
		if asset.use_autotiling:
			layer_node.set_cells_terrain_connect([cell], asset.terrain_set, asset.terrain, true)
		else:
			layer_node.set_cell(cell, asset.source_id, asset.atlas_coords)

func _unhandled_input(event: InputEvent) -> void:
	if not is_brush_mode or not multiplayer.is_server():
		return
		
	var is_painting = false
	var touch_pos = Vector2.ZERO
	
	if event is InputEventScreenDrag or event is InputEventMouseMotion:
		var is_mouse_down = (event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT))
		if event is InputEventScreenDrag or is_mouse_down:
			is_painting = true
			touch_pos = event.position
			
	elif event is InputEventScreenTouch and event.pressed:
		is_painting = true
		touch_pos = event.position
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		is_painting = true
		touch_pos = event.position
		
	if is_painting:
		var zoom = get_viewport().get_camera_2d().zoom if get_viewport().get_camera_2d() else Vector2.ONE
		var cam_pos = get_viewport().get_camera_2d().global_position if get_viewport().get_camera_2d() else Vector2.ZERO
		var screen_center = get_viewport_rect().size / 2.0
		
		# world_pos correta compensando câmera
		var world_pos = cam_pos + (touch_pos - screen_center) / zoom
		
		var cell = world_to_grid(world_pos)
		if is_cell_valid(cell):
			var current_asset = ""
			if current_brush_asset != "" and current_brush_asset != "eraser":
				var a = TilesetManager.get_asset(current_brush_asset)
				if a:
					current_asset = _grid_data[cell][a.default_layer]
			else:
				# Eraser
				current_asset = _grid_data[cell].get(current_layer_focus, "")
				
			if current_asset != current_brush_asset or current_brush_asset == "eraser":
				if is_fill_mode:
					# O preenchimento funciona apenas para Terrenos!
					if current_layer_focus == "Ground":
						if event is InputEventScreenTouch and event.pressed or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
							_perform_flood_fill(cell, current_asset, current_brush_asset)
				else:
					if current_brush_asset == "eraser":
						sync_cell_erase(cell, current_layer_focus)
						rpc("sync_cell_erase", cell, current_layer_focus)
					else:
						sync_cell(cell, current_brush_asset)
						rpc("sync_cell", cell, current_brush_asset)

func _perform_flood_fill(start_cell: Vector2i, target_asset: String, replacement_asset: String) -> void:
	if target_asset == replacement_asset:
		return
		
	# Flood fill apenas para Ground layers faz mais sentido, mas vamos basear no target_asset local.
	var queue = [start_cell]
	var cells_to_update: Array[Vector2i] = []
	var visited = {}
	
	while queue.size() > 0:
		var cell = queue.pop_front()
		if not is_cell_valid(cell):
			continue
		if visited.has(cell):
			continue
			
		visited[cell] = true
		
		var a = TilesetManager.get_asset(replacement_asset)
		var target_layer = a.default_layer if a else "Ground"
		var val = _grid_data[cell][target_layer]
		
		if val == target_asset:
			cells_to_update.append(cell)
			queue.append(cell + Vector2i(1, 0))
			queue.append(cell + Vector2i(-1, 0))
			queue.append(cell + Vector2i(0, 1))
			queue.append(cell + Vector2i(0, -1))
			
	if cells_to_update.size() > 0:
		sync_cells(cells_to_update, replacement_asset)
		rpc("sync_cells", cells_to_update, replacement_asset)

@rpc("authority", "call_local", "reliable")
func sync_cells(cells: Array[Vector2i], asset_id: String) -> void:
	var asset = TilesetManager.get_asset(asset_id)
	
	if asset_id == "":
		for cell in cells:
			_grid_data[cell] = {"Ground": "", "Objects": "", "Effects": ""}
			ground_layer.set_cell(cell, -1)
			objects_layer.set_cell(cell, -1)
			effects_layer.set_cell(cell, -1)
		return
		
	if asset:
		var layer = asset.default_layer
		for cell in cells:
			_grid_data[cell][layer] = asset_id
			
		if asset.use_autotiling:
			var layer_node: TileMapLayer = null
			match asset.default_layer:
				"Ground": layer_node = ground_layer
				"Objects": layer_node = objects_layer
				"Effects": layer_node = effects_layer
			if layer_node:
				layer_node.set_cells_terrain_connect(cells, asset.terrain_set, asset.terrain, true)
		else:
			for cell in cells:
				_paint_asset_on_layer(cell, asset)

@rpc("authority", "call_local", "reliable")
func sync_cell(cell: Vector2i, asset_id: String) -> void:
	if asset_id == "":
		return
		
	var asset = TilesetManager.get_asset(asset_id)
	if asset:
		_grid_data[cell][asset.default_layer] = asset_id
		_paint_asset_on_layer(cell, asset)

@rpc("authority", "call_local", "reliable")
func sync_cell_erase(cell: Vector2i, layer_focus: String) -> void:
	if _grid_data.has(cell):
		_grid_data[cell][layer_focus] = ""
	
	match layer_focus:
		"Ground":
			ground_layer.set_cell(cell, -1)
			# Para autotiling Godot, atualizar a vizinhança sem essa célula
			ground_layer.set_cells_terrain_connect([cell], 0, -1, true)
		"Objects":
			objects_layer.set_cell(cell, -1)
		"Effects":
			effects_layer.set_cell(cell, -1)

@rpc("authority", "call_local", "reliable")
func clear_map() -> void:
	_grid_data.clear()
	ground_layer.clear()
	objects_layer.clear()
	effects_layer.clear()
	_init_grid()



func grid_to_world(cell: Vector2i) -> Vector2:
	return ground_layer.map_to_local(cell)

func world_to_grid(pos: Vector2) -> Vector2i:
	return ground_layer.local_to_map(ground_layer.to_local(pos))

func is_cell_valid(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < map_size.x and cell.y >= 0 and cell.y < map_size.y
