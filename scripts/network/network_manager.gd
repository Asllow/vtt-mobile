extends Node

signal peer_connected(id: int)
signal peer_disconnected(id: int)
signal connected_to_server
signal connection_failed
signal server_disconnected

const DEFAULT_PORT = 7000
const BROADCAST_PORT = 8999

var is_host: bool = false
var peer: ENetMultiplayerPeer

var udp_broadcaster: PacketPeerUDP
var udp_listener: PacketPeerUDP
var broadcast_timer: Timer
var server_session_id: String = ""
var current_port: int = DEFAULT_PORT

var local_player_name: String = "Jogador"
var players: Dictionary = {} # id (int): name (String)

signal session_found(session_id: String, ip: String, port: int, table_name: String, master_name: String)
signal players_updated

func host_game(table_name: String = "Mesa", master_name: String = "Mestre") -> Error:
	local_player_name = master_name
	peer = ENetMultiplayerPeer.new()
	current_port = randi_range(7000, 8000)
	var err = peer.create_server(current_port)
	var attempts = 0
	while err != OK and attempts < 100:
		current_port = randi_range(7000, 8000)
		peer = ENetMultiplayerPeer.new()
		err = peer.create_server(current_port)
		attempts += 1
		
	if err != OK:
		return err
	
	server_session_id = str(randi())
	
	multiplayer.multiplayer_peer = peer
	is_host = true
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	_setup_udp_broadcaster(table_name, master_name)
	
	players[1] = local_player_name
	players_updated.emit()
	
	return OK

func _setup_udp_broadcaster(table_name: String, master_name: String) -> void:
	udp_broadcaster = PacketPeerUDP.new()
	udp_broadcaster.set_broadcast_enabled(true)
	udp_broadcaster.set_dest_address("255.255.255.255", BROADCAST_PORT)
	
	broadcast_timer = Timer.new()
	broadcast_timer.wait_time = 1.0
	broadcast_timer.autostart = true
	broadcast_timer.timeout.connect(func(): _broadcast_presence(table_name, master_name))
	add_child(broadcast_timer)

func _broadcast_presence(table_name: String, master_name: String) -> void:
	if udp_broadcaster:
		var data = {"id": server_session_id, "t": table_name, "m": master_name, "p": current_port}
		var buffer = JSON.stringify(data).to_utf8_buffer()
		
		# Padrão
		udp_broadcaster.set_dest_address("255.255.255.255", BROADCAST_PORT)
		udp_broadcaster.put_packet(buffer)
		
		# Força o broadcast em todas as placas de rede (resolve o problema do Hotspot no Android)
		for ip in IP.get_local_addresses():
			if ip.count(".") == 3 and not ip.begins_with("127."):
				var parts = ip.split(".")
				parts[3] = "255"
				var bcast = ".".join(parts)
				udp_broadcaster.set_dest_address(bcast, BROADCAST_PORT)
				udp_broadcaster.put_packet(buffer)

func start_lan_discovery() -> void:
	udp_listener = PacketPeerUDP.new()
	udp_listener.bind(BROADCAST_PORT)

func stop_lan_discovery() -> void:
	if udp_listener:
		udp_listener.close()
		udp_listener = null

func leave_game() -> void:
	if multiplayer.has_multiplayer_peer():
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	
	peer = null
	is_host = false
	server_session_id = ""
	players.clear()
	
	if broadcast_timer:
		broadcast_timer.stop()
		broadcast_timer.queue_free()
		broadcast_timer = null
		
	if udp_broadcaster:
		udp_broadcaster.close()
		udp_broadcaster = null
		
	stop_lan_discovery()

func _process(_delta: float) -> void:
	if udp_listener and udp_listener.is_bound():
		while udp_listener.get_available_packet_count() > 0:
			var packet = udp_listener.get_packet()
			var ip = udp_listener.get_packet_ip()
			var text = packet.get_string_from_utf8()
			var data = JSON.parse_string(text)
			if typeof(data) == TYPE_DICTIONARY:
				if data.has("id") and data.has("t") and data.has("m") and data.has("p"):
					session_found.emit(data["id"], ip, int(data["p"]), data["t"], data["m"])

func join_game(ip: String, port: int = DEFAULT_PORT) -> Error:
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip, port)
	if err != OK:
		return err
		
	multiplayer.multiplayer_peer = peer
	is_host = false
	
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	players[multiplayer.get_unique_id()] = local_player_name
	
	return OK

func _on_peer_connected(id: int) -> void:
	peer_connected.emit(id)

func _on_peer_disconnected(id: int) -> void:
	peer_disconnected.emit(id)

func _on_connected_to_server() -> void:
	register_player.rpc_id(1, local_player_name)
	connected_to_server.emit()

func _on_connection_failed() -> void:
	connection_failed.emit()

func _on_server_disconnected() -> void:
	players.clear()
	players_updated.emit()
	server_disconnected.emit()

@rpc("any_peer", "call_remote", "reliable")
func register_player(p_name: String) -> void:
	var id = multiplayer.get_remote_sender_id()
	players[id] = p_name
	if is_host:
		_send_player_info_to_all.rpc(players)
		players_updated.emit()

@rpc("authority", "call_remote", "reliable")
func _send_player_info_to_all(info: Dictionary) -> void:
	players = info
	players_updated.emit()
