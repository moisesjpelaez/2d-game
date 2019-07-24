extends CanvasLayer

export (Texture) var Heart

func _ready():
	Global.game_label = $Control/Label
	Global.restart_timer = $RestartTimer
	Global.ui_health = $Control/Health
	Global.heart_texture = Heart
	randomize()
	Global.game_music = get_node("Music" + str(randi() % 6 + 1))
	
	$Control/Health.hide()
	$Control/Label.text = "press the spacebar to start\n press 'esc' to quit"
	
	$RestartTimer.connect("timeout", self, "_on_RestartTimer_timeout")

	Global.game_is_over = false
	Global.can_restart = false

	if Global.game_started:
		Global.start_game()

	for i in range(1,7):
		get_node("Music" + str(i)).connect("finished", self, "change_music")

func _on_RestartTimer_timeout():
	Global.show_restart()

func change_music():
	randomize()
	Global.game_music = get_node("Music" + str(randi() % 6 + 1))
	Global.game_music.play()

