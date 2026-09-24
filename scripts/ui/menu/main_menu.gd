extends Control

signal host_requested(table_name: String, player_name: String, grid_size: Vector2i)
signal join_requested(table_code: String, player_name: String, ip: String, port: int)

@onready var main_panel: Control = $MainPanel
@onready var host_panel: Control = $HostPanel
@onready var client_panel: Control = $ClientPanel

# Host inputs
@onready var host_table_name: LineEdit = $HostPanel/VBoxContainer/VBoxContainer/TableNameInput
@onready var host_player_name: LineEdit = $HostPanel/VBoxContainer/VBoxContainer2/PlayerNameInput
@onready var host_grid_x: LineEdit = $HostPanel/VBoxContainer/GridSizeContainer/GridXInput
@onready var host_grid_y: LineEdit = $HostPanel/VBoxContainer/GridSizeContainer/GridYInput

# Client inputs
@onready var client_player_name: LineEdit = $ClientPanel/VBoxContainer/VBoxContainer2/PlayerNameInput
@onready var session_list_container: VBoxContainer = $ClientPanel/VBoxContainer/ScrollContainer/SessionListPadding/SessionListContainer
@onready var label_sessions: Label = $ClientPanel/VBoxContainer/LabelSessions

var _discovered_sessions = {} # session_id : { "ip": ip, "port": port }
var _selected_session_id: String = ""

func _ready() -> void:
	_show_panel(main_panel)
	NetworkManager.session_found.connect(_on_session_found)

func _show_panel(panel: Control) -> void:
	main_panel.visible = false
	host_panel.visible = false
	client_panel.visible = false
	panel.visible = true
	
	if panel == client_panel:
		_discovered_sessions.clear()
		for child in session_list_container.get_children():
			child.queue_free()
		_selected_session_id = ""
		_update_sessions_count()
		NetworkManager.start_lan_discovery()
	else:
		NetworkManager.stop_lan_discovery()

func _update_sessions_count() -> void:
	var count = _discovered_sessions.size()
	label_sessions.text = "Sessões Ativas na LAN (%d)" % count

# --- Main Panel ---
func _on_create_table_button_pressed() -> void:
	_show_panel(host_panel)

func _on_join_table_button_pressed() -> void:
	_show_panel(client_panel)

func _on_settings_button_pressed() -> void:
	pass # TODO: Settings

# --- Host Panel ---
func _on_host_create_button_pressed() -> void:
	var t_name = host_table_name.text if host_table_name.text != "" else "Mesa 1"
	var p_name = host_player_name.text if host_player_name.text != "" else "Mestre"
	var gx = int(host_grid_x.text) if host_grid_x.text.is_valid_int() else 20
	var gy = int(host_grid_y.text) if host_grid_y.text.is_valid_int() else 20
	
	host_requested.emit(t_name, p_name, Vector2i(gx, gy))

func _on_host_back_button_pressed() -> void:
	_show_panel(main_panel)

# --- Client Panel ---
func _on_session_found(session_id: String, ip: String, port: int, table_name: String, master_name: String) -> void:
	if not _discovered_sessions.has(session_id):
		_discovered_sessions[session_id] = {"ip": ip, "port": port}
		
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(260, 68) # Maior para não cortar bordas
		btn.pressed.connect(func(): _on_session_button_pressed(session_id, btn))
		
		var margin = MarginContainer.new()
		margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		margin.add_theme_constant_override("margin_top", 10)
		margin.add_theme_constant_override("margin_bottom", 10)
		margin.add_theme_constant_override("margin_left", 10)
		margin.add_theme_constant_override("margin_right", 10)
		btn.add_child(margin)
		
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		margin.add_child(vbox)
		
		var lbl_room = Label.new()
		lbl_room.text = "Sala: " + table_name
		lbl_room.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_room.add_theme_color_override("font_color", Color(0.9, 0.85, 0.75))
		vbox.add_child(lbl_room)
		
		var lbl_master = Label.new()
		lbl_master.text = "Gamemaster: " + master_name
		lbl_master.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_master.add_theme_color_override("font_color", Color(0.65, 0.6, 0.55))
		lbl_master.add_theme_font_size_override("font_size", 12)
		vbox.add_child(lbl_master)
		
		session_list_container.add_child(btn)
		_update_sessions_count()

func _on_session_button_pressed(session_id: String, btn: Button) -> void:
	_selected_session_id = session_id
	for child in session_list_container.get_children():
		child.modulate = Color(1.0, 1.0, 1.0, 1.0)
	btn.modulate = Color(1.5, 1.2, 0.8, 1.0)

func _on_client_join_button_pressed() -> void:
	if _selected_session_id == "":
		return # Nenhuma sessão selecionada
		
	var session_data = _discovered_sessions[_selected_session_id]
	var p_name = client_player_name.text if client_player_name.text != "" else "Jogador"
	
	join_requested.emit("N/A", p_name, session_data["ip"], session_data["port"])

func _on_client_back_button_pressed() -> void:
	_show_panel(main_panel)
