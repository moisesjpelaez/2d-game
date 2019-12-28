extends CanvasLayer

export (Texture) var Heart
export var total_music = 8

export var debug_music = 5

func _ready():
	Global.game_label = $Control/Label
	Global.restart_timer = $RestartTimer
	Global.ui_health = $Control/Health
	Global.heart_texture = Heart
	randomize()
	Global.game_music = get_node("GameMusic" + str(randi() % total_music + 1))
	# Global.game_music = get_node("GameMusic" + str(debug_music))

	$Control/Health.hide()
	$Control/Label.text = "press the spacebar to start"
	
	$RestartTimer.connect("timeout", self, "_on_RestartTimer_timeout")

	Global.game_is_over = false
	Global.can_restart = false

	if Global.game_started:
		Global.start_game()

	for i in range(1, total_music + 1):
		get_node("GameMusic" + str(i)).connect("finished", self, "change_music")

func _on_RestartTimer_timeout():
	Global.show_restart()

func change_music():
	Global.game_music = get_node("GameMusic" + str(randi() % total_music + 1))
	Global.game_music.play()
