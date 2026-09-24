extends Control

@onready var slide_container: Control = $SlideContainer
@onready var show_button: Button = $ShowButton
@onready var players_list: VBoxContainer = $SlideContainer/PanelContainer/VBoxContainer/ScrollContainer/PlayersList

func _ready() -> void:
	slide_container.position.y = -600
	slide_container.hide()
	show_button.show()
	
	# Atualiza a lista de players periodicamente (se o menu estiver aberto)
	var t = Timer.new()
	t.wait_time = 2.0
	t.autostart = true
	NetworkManager.players_updated.connect(_update_players)
	add_child(t)

func _update_players() -> void:
	if not slide_container.visible:
		return
	if not multiplayer.has_multiplayer_peer():
		return
		
	for child in players_list.get_children():
		child.queue_free()
	
	for id in NetworkManager.players:
		var is_host = (id == 1)
		var is_you = (id == multiplayer.get_unique_id())
		var name_str = NetworkManager.players[id]
		
		var lbl_str = name_str
		if is_you:
			lbl_str += " (Você)"
		if is_host:
			lbl_str += " [HOST]"
			
		_add_player_label(lbl_str)

func _add_player_label(text: String) -> void:
	var lbl = Label.new()
	lbl.text = " ⚔ " + text
	lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	players_list.add_child(lbl)

func _on_hide_button_pressed() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(slide_container, "position:y", -600.0, 0.3)
	tween.tween_callback(func():
		slide_container.hide()
		show_button.show()
	)

func _on_show_button_pressed() -> void:
	show_button.hide()
	slide_container.show()
	_update_players()
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# Desliza para posição Y = 20 (borda flutuante)
	tween.tween_property(slide_container, "position:y", 20.0, 0.3)

func _on_btn_leave_pressed() -> void:
	NetworkManager.leave_game()
	
	# Reinicia completamente a cena para limpar o mapa, variáveis de rede e UI
	get_tree().reload_current_scene()
