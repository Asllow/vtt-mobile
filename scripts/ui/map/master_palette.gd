extends Control

@onready var grid_container: GridContainer = $SlideContainer/PanelContainer/VBoxContainer/ScrollContainer/GridContainer
@onready var btn_brush: Button = $SlideContainer/PanelContainer/VBoxContainer/Tools/BtnBrush
@onready var btn_eraser: Button = $SlideContainer/PanelContainer/VBoxContainer/Tools/BtnEraser

@onready var btn_ground: Button = $SlideContainer/PanelContainer/VBoxContainer/Categories/BtnGround
@onready var btn_objects: Button = $SlideContainer/PanelContainer/VBoxContainer/Categories/BtnObjects
@onready var btn_tokens: Button = $SlideContainer/PanelContainer/VBoxContainer/Categories/BtnTokens
@onready var btn_effects: Button = $SlideContainer/PanelContainer/VBoxContainer/Categories/BtnEffects

@onready var slide_container: Control = $SlideContainer
@onready var show_button: Button = $ShowButton

var current_category: String = "Ground"

func _ready() -> void:
	_populate_grid(current_category)
	_update_tool_buttons("none")
	slide_container.position.y = 300.0
	slide_container.hide()
	show_button.show()

func _populate_grid(category: String) -> void:
	current_category = category
	_update_category_buttons()
	
	var root = get_parent().get_parent() if get_parent() else null
	if root and root.has_node("Map"):
		root.get_node("Map").current_layer_focus = category
		
	# Clear grid
	for child in grid_container.get_children():
		child.queue_free()
		
	# Populate grid from TilesetManager
	var all_assets = TilesetManager.asset_registry
	for asset_id in all_assets:
		var asset: AssetData = all_assets[asset_id]
		if asset.default_layer == category:
			var btn = Button.new()
			btn.custom_minimum_size = Vector2(64, 64)
			
			# Extract a thumbnail from the atlas texture
			if asset.texture:
				var atlas_tex = AtlasTexture.new()
				atlas_tex.atlas = asset.texture
				atlas_tex.region = Rect2(asset.atlas_coords.x * 64, asset.atlas_coords.y * 64, 64, 64)
				var tex_rect = TextureRect.new()
				tex_rect.texture = atlas_tex
				tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				tex_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
				btn.add_child(tex_rect)
			else:
				btn.text = asset_id.split(".")[1].capitalize()
				
			btn.set_meta("asset_id", asset_id)
			btn.pressed.connect(func(): _on_asset_selected(asset_id))
			grid_container.add_child(btn)
			
	_update_asset_highlights()

func _update_category_buttons() -> void:
	var active_color = Color(1.0, 0.8, 0.4)
	var inactive_color = Color(0.85, 0.8, 0.7)
	
	btn_ground.add_theme_color_override("font_color", active_color if current_category == "Ground" else inactive_color)
	btn_objects.add_theme_color_override("font_color", active_color if current_category == "Objects" else inactive_color)
	btn_tokens.add_theme_color_override("font_color", active_color if current_category == "Tokens" else inactive_color)
	btn_effects.add_theme_color_override("font_color", active_color if current_category == "Effects" else inactive_color)

func _on_asset_selected(asset_id: String) -> void:
	var root = get_parent().get_parent() if get_parent() else null
	if root and root.has_node("Map"):
		var grid_manager = root.get_node("Map")
		
		# Toggle off if clicking the active asset while already in brush mode
		if grid_manager.current_brush_asset == asset_id and grid_manager.is_brush_mode and not grid_manager.is_fill_mode:
			grid_manager.is_brush_mode = false
			_update_tool_buttons("none")
			if root.has_node("Camera2D"):
				root.get_node("Camera2D").is_brush_mode = false
		else:
			grid_manager.current_brush_asset = asset_id
			grid_manager.is_brush_mode = true
			if not grid_manager.is_fill_mode:
				_update_tool_buttons("brush")
			else:
				_update_tool_buttons("fill")
			if root.has_node("Camera2D"):
				root.get_node("Camera2D").is_brush_mode = true
				
	_update_asset_highlights()

func _update_asset_highlights() -> void:
	var root = get_parent().get_parent() if get_parent() else null
	var current_asset = ""
	var is_active = false
	if root and root.has_node("Map"):
		current_asset = root.get_node("Map").current_brush_asset
		is_active = root.get_node("Map").is_brush_mode
		
	for child in grid_container.get_children():
		if child.has_meta("asset_id"):
			if child.get_meta("asset_id") == current_asset and is_active:
				child.modulate = Color(1.2, 1.2, 1.2, 1.0)
			else:
				child.modulate = Color(0.5, 0.5, 0.5, 1.0)

func _on_category_pressed(category: String) -> void:
	_populate_grid(category)

func _on_btn_brush_pressed() -> void:
	var root = get_parent().get_parent() if get_parent() else null
	if root and root.has_node("Map"):
		var grid_manager = root.get_node("Map")
		if grid_manager.is_brush_mode and not grid_manager.is_fill_mode and grid_manager.current_brush_asset != "":
			grid_manager.is_brush_mode = false
			_update_tool_buttons("none")
			if root.has_node("Camera2D"):
				root.get_node("Camera2D").is_brush_mode = false
		else:
			grid_manager.is_brush_mode = true
			grid_manager.is_fill_mode = false
			_update_tool_buttons("brush")
			if root.has_node("Camera2D"):
				root.get_node("Camera2D").is_brush_mode = true
	_update_asset_highlights()

func _on_btn_eraser_pressed() -> void:
	var root = get_parent().get_parent() if get_parent() else null
	if root and root.has_node("Map"):
		var grid_manager = root.get_node("Map")
		if grid_manager.is_brush_mode and not grid_manager.is_fill_mode and grid_manager.current_brush_asset == "":
			grid_manager.is_brush_mode = false
			_update_tool_buttons("none")
			if root.has_node("Camera2D"):
				root.get_node("Camera2D").is_brush_mode = false
		else:
			grid_manager.current_brush_asset = "eraser"
			grid_manager.is_brush_mode = true
			grid_manager.is_fill_mode = false
			_update_tool_buttons("eraser")
			if root.has_node("Camera2D"):
				root.get_node("Camera2D").is_brush_mode = true
	_update_asset_highlights()

func _on_btn_fill_pressed() -> void:
	var root = get_parent().get_parent() if get_parent() else null
	if root and root.has_node("Map"):
		var grid_manager = root.get_node("Map")
		if grid_manager.is_fill_mode:
			grid_manager.is_fill_mode = false
			grid_manager.is_brush_mode = false
			_update_tool_buttons("none")
			if root.has_node("Camera2D"):
				root.get_node("Camera2D").is_brush_mode = false
		else:
			if grid_manager.current_brush_asset != "" and grid_manager.current_brush_asset != "eraser":
				grid_manager.is_brush_mode = true
				grid_manager.is_fill_mode = true
				_update_tool_buttons("fill")
				if root.has_node("Camera2D"):
					root.get_node("Camera2D").is_brush_mode = true

func _on_btn_clear_pressed() -> void:
	var root = get_parent().get_parent() if get_parent() else null
	if root and root.has_node("Map"):
		var grid_manager = root.get_node("Map")
		if grid_manager.multiplayer.is_server():
			grid_manager.rpc("clear_map")

func _update_tool_buttons(active_tool: String) -> void:
	var active_color = Color(1.0, 0.8, 0.4)
	var inactive_color = Color(0.85, 0.8, 0.7)
	
	btn_brush.add_theme_color_override("font_color", active_color if active_tool == "brush" else inactive_color)
	btn_eraser.add_theme_color_override("font_color", active_color if active_tool == "eraser" else inactive_color)
	
	var btn_fill = $SlideContainer/PanelContainer/VBoxContainer/Tools/BtnFill
	if btn_fill:
		btn_fill.add_theme_color_override("font_color", active_color if active_tool == "fill" else inactive_color)

func _on_hide_button_pressed() -> void:
	var root = get_parent().get_parent() if get_parent() else null
	if root and root.has_node("Map"):
		var grid_manager = root.get_node("Map")
		grid_manager.is_brush_mode = false
		grid_manager.is_fill_mode = false
		if root.has_node("Camera2D"):
			root.get_node("Camera2D").is_brush_mode = false
			
	_update_tool_buttons("none")
	_update_asset_highlights()
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	# Desliza 300 pixels pra baixo pra sair da tela
	tween.tween_property(slide_container, "position:y", 300.0, 0.3)
	tween.tween_callback(func(): 
		slide_container.hide()
		show_button.show()
	)

func _on_show_button_pressed() -> void:
	show_button.hide()
	slide_container.show()
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(slide_container, "position:y", 0.0, 0.3)
