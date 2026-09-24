extends Control

const CURRENT_VERSION = "0.5.0"
# URL base que vai apontar pro arquivo version.json no GitHub (Raw)
var VERSION_URL = "https://raw.githubusercontent.com/Asllow/vtt-mobile/main/version.json"

@onready var status_label: Label = $VBoxContainer/StatusLabel
@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar
@onready var retry_button: Button = $VBoxContainer/RetryButton

var http_version: HTTPRequest
var http_download: HTTPRequest

var patch_url: String = ""
var is_downloading := false

func _ready() -> void:
	# Cria os nós de requisição HTTP
	http_version = HTTPRequest.new()
	http_version.request_completed.connect(_on_version_request_completed)
	add_child(http_version)
	
	http_download = HTTPRequest.new()
	http_download.request_completed.connect(_on_download_completed)
	add_child(http_download)
	
	retry_button.hide()
	
	# Verifica se já temos um patch salvo de atualizações anteriores para carregar agora!
	_inject_saved_patch()
	
	# Aguarda um pouquinho pra tela respirar e checa se tem algo novo
	await get_tree().create_timer(1.0).timeout
	check_for_updates()

func check_for_updates() -> void:
	status_label.text = "Verificando atualizações..."
	progress_bar.hide()
	retry_button.hide()
	
	var err = http_version.request(VERSION_URL)
	if err != OK:
		_fail("Falha ao iniciar verificação de rede.")

func _on_version_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		# Se der erro de rede (offline), apenas entra no jogo normalmente com a versão que tem
		print("Modo offline ou erro ao checar versão. Iniciando jogo local...")
		start_game()
		return
		
	var json = JSON.parse_string(body.get_string_from_utf8())
	if typeof(json) != TYPE_DICTIONARY:
		start_game()
		return
		
	var latest_version = str(json.get("version", CURRENT_VERSION))
	patch_url = json.get("pck_url", "")
	
	# Compara as strings de versão (ex: "0.5.0" vs "0.4.0")
	if _is_version_greater(latest_version, CURRENT_VERSION) and patch_url != "":
		# Tem atualização!
		status_label.text = "Baixando atualização... Por favor, aguarde."
		progress_bar.show()
		progress_bar.value = 0
		start_download()
	else:
		status_label.text = "Jogo atualizado!"
		await get_tree().create_timer(0.5).timeout
		start_game()

func _is_version_greater(v1: String, v2: String) -> bool:
	var parts1 = v1.split(".")
	var parts2 = v2.split(".")
	for i in range(max(parts1.size(), parts2.size())):
		var num1 = int(parts1[i]) if i < parts1.size() else 0
		var num2 = int(parts2[i]) if i < parts2.size() else 0
		if num1 > num2:
			return true
		elif num1 < num2:
			return false
	return false

func start_download() -> void:
	# O arquivo será salvo na pasta interna do aplicativo
	http_download.download_file = "user://patch.pck"
	var err = http_download.request(patch_url)
	if err != OK:
		_fail("Erro ao iniciar o download da atualização.")
	else:
		is_downloading = true

func _process(delta: float) -> void:
	if is_downloading and http_download.get_body_size() > 0:
		var downloaded = http_download.get_downloaded_bytes()
		var total = http_download.get_body_size()
		progress_bar.max_value = total
		progress_bar.value = downloaded

func _on_download_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	is_downloading = false
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		_fail("O download falhou. Código: " + str(response_code))
		return
		
	status_label.text = "Atualização concluída! Aplicando..."
	
	# Ao baixar, nós carregamos o pacote imediatamente
	_inject_saved_patch()
	
	await get_tree().create_timer(1.0).timeout
	start_game()

func _inject_saved_patch() -> void:
	# Essa é a mágica do Godot. Se o arquivo PCK existir, ele sobrepõe todas as pastas "res://"
	if FileAccess.file_exists("user://patch.pck"):
		var success = ProjectSettings.load_resource_pack("user://patch.pck")
		if success:
			print("Patch carregado com sucesso!")
		else:
			print("Falha ao carregar patch. Pode estar corrompido.")

func start_game() -> void:
	# Troca para a tela principal
	get_tree().change_scene_to_file("res://scenes/main/Main.tscn")

func _fail(msg: String) -> void:
	status_label.text = msg
	retry_button.show()

func _on_retry_button_pressed() -> void:
	check_for_updates()
