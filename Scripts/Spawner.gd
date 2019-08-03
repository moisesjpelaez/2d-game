extends Position2D

export (PackedScene) var Enemy
var min_time = 5.0
var max_time = 10.0

func _ready():
	Global.connect("start_game", self, "_on_Global_start_game")
	$Timer.connect("timeout", self, "_on_Timer_timeout")

	if Global.game_started:
		_on_Global_start_game()

func _on_Timer_timeout():
	if Global.game_is_over:
		$Timer.stop()
		return
		
	randomize()
	$Timer.wait_time = randf() * max_time + min_time
	var enemy = Enemy.instance()
	enemy.position = position
	get_tree().get_root().get_node("Game/EnemySpawners").add_child(enemy)

func _on_Global_start_game():
	randomize()
	$Timer.wait_time = randf() * max_time + min_time
	# $Timer.start()
