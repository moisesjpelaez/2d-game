extends Node

var player
var player_lives = 2

var game_is_over = false
var game_label
var restart_timer
var game_started = false
var ui_health
var heart_texture
var can_restart = false
var game_music

var restart_text = "press the spacebar to try again"
var game_over_text = "game over"

signal start_game
signal shake_screen(amount, duration)

func start_game():
	player_lives = 2
	game_label.hide()
	ui_health.show()
	emit_signal("start_game")
	
	if game_music != null:
		game_music.play()
		game_music.get_node("AnimationPlayer").play("FadeIn")

func game_over():
	game_is_over = true
	game_label.show()
	ui_health.hide()
	game_label.text = game_over_text
	restart_timer.start()
	
	if game_music != null:
		game_music.get_node("AnimationPlayer").play("FadeOut")

func show_restart():
	game_label.text = restart_text
	can_restart = true

func _input(event):
	if event.is_action_pressed("jump") && !game_started:
		game_started = true
		game_is_over = false
		start_game()
	if event.is_action_pressed("jump") && can_restart:
		get_tree().reload_current_scene()
	if event.is_action_pressed("quit"):
		get_tree().quit()
