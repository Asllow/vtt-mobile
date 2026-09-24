extends Node2D

const TOKEN_SCENE = preload("res://scenes/token/Token.tscn")

@onready var grid_manager: GridManager = $Map
@onready var tokens_container: Node2D = $Map/TokensLayer

var room_state := {
	"tokens": {}, # id: { "owner": int, "x": int, "y": int }
	"grid": {}    # "x,y": tile_id
}

func _ready() -> void:
	if tokens_container:
		tokens_container.y_sort_enabled = true
		
	if has_node("UI/MainMenu"):
		var menu = $UI/MainMenu
		menu.host_requested.connect(_on_host_requested)
		menu.join_requested.connect(_on_join_requested)

# Chamado por algum botão UI de "Criar Sala"
func start_host(table_name: String = "Mesa", master_name: String = "Mestre") -> void:
	NetworkManager.stop_lan_discovery()
	var err = NetworkManager.host_game(table_name, master_name)
	if err == OK:
		_setup_initial_room()
		NetworkManager.peer_connected.connect(_on_peer_joined)

# Chamado por algum botão UI de "Entrar na Sala"
func start_client(ip: String, port: int, player_name: String) -> void:
	NetworkManager.local_player_name = player_name
	NetworkManager.stop_lan_discovery()
	NetworkManager.join_game(ip, port)

func _on_host_requested(table_name: String, player_name: String, _grid_size: Vector2i) -> void:
	start_host(table_name, player_name)
	if has_node("UI/MainMenu"):
		$UI/MainMenu.hide()
	if has_node("UI/MasterPalette"):
		$UI/MasterPalette.show()
	if has_node("UI/SessionMenu"):
		$UI/SessionMenu.show()

func _on_join_requested(_table_code: String, player_name: String, ip: String, port: int) -> void:
	start_client(ip, port, player_name)
	if has_node("UI/MainMenu"):
		$UI/MainMenu.hide()
	if has_node("UI/SessionMenu"):
		$UI/SessionMenu.show()
	


func _setup_initial_room() -> void:
	# Apenas o Host inicializa a sala.
	add_token_to_state("token_1", 1, Vector2i(2, 2))
	add_token_to_state("token_2", 1, Vector2i(5, 5))
	_spawn_all_tokens_from_state()

func add_token_to_state(id: String, token_owner: int, cell: Vector2i) -> void:
	room_state["tokens"][id] = {
		"owner": token_owner,
		"x": cell.x,
		"y": cell.y
	}

func _spawn_all_tokens_from_state() -> void:
	for child in tokens_container.get_children():
		child.queue_free()
		
	for token_id in room_state["tokens"]:
		var data = room_state["tokens"][token_id]
		var token: Token = TOKEN_SCENE.instantiate()
		token.name = token_id # Nome do Node precisa ser idêntico para o RPC funcionar
		tokens_container.add_child(token)
		token.setup(token_id, data["owner"], Vector2i(data["x"], data["y"]), grid_manager)

func _on_peer_joined(peer_id: int) -> void:
	if NetworkManager.is_host:
		# Atualiza o estado da grid antes de enviar
		room_state["grid"] = grid_manager.get_map_data()
		# Envia o estado completo para quem acabou de entrar
		rpc_id(peer_id, "receive_snapshot", room_state)

@rpc("authority", "call_remote", "reliable")
func receive_snapshot(state: Dictionary) -> void:
	room_state = state
	_spawn_all_tokens_from_state()
	if room_state.has("grid"):
		grid_manager.load_map_data(room_state["grid"])
