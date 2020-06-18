extends CanvasLayer

const MUSIC_PATH = "res://Music/"
const MUSIC_SCENE = preload("res://Scenes/GameMusic.tscn")
onready var music_node = $Music
var music_list = []

export var set_music = false
export (Texture) var Heart
export var total_music = 7

export var debug_music = 5

func _ready():
	Global.game_label = $Control/Label
	Global.restart_timer = $RestartTimer
	Global.ui_health = $Control/Health
	Global.heart_texture = Heart
	
	if set_music:
		assign_tracks()
		
		randomize()
		Global.game_music = music_node.get_child(randi() % total_music + 1)
		
		for i in music_list.size():
			music_node.get_child(i).connect("finished", self, "change_music")

	$Control/Health.hide()
	$Control/Label.text = "press the spacebar to start"
	
	$RestartTimer.connect("timeout", self, "_on_RestartTimer_timeout")

	Global.game_is_over = false
	Global.can_restart = false

	if Global.game_started:
		Global.start_game()

func get_music(path):
	var files = []
	var dir = Directory.new()
	
	if dir.open(path) == OK:
		dir.list_dir_begin()
		while true:
			var file_name = dir.get_next()
			if file_name == "":
				break
			if file_name.ends_with(".import"):
				files.append(load(path + file_name.replace(".import", "")))
		dir.list_dir_end()
	
	return files

func assign_tracks():
	music_list = get_music(MUSIC_PATH)
	
	for music in music_list:
		var music_scene = MUSIC_SCENE.instance()
		music_node.add_child(music_scene)
		music_scene.stream = music
		music_scene.volume_db = -10

func _on_RestartTimer_timeout():
	Global.show_restart()

func change_music():
	if !set_music:
		return
	
	if !Global.game_is_over:
		Global.game_music = music_node.get_child(randi() % total_music + 1)
		Global.game_music.play()
