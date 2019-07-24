extends Position2D

export (PackedScene) var Enemy
var min_time = 5.0
var max_time = 10.0

func _ready():
	randomize()
	$Timer.connect("timeout", self, "_on_Timer_timeout")
	$Timer.wait_time = randf() * max_time + min_time
func _on_Timer_timeout():
	if Global.game_over:
		$Timer.autostart = false
		return
		
	randomize()
	$Timer.wait_time = randf() * max_time + min_time
	var enemy = Enemy.instance()
	enemy.position = position
	get_tree().get_root().get_node("Game/EnemySpawners").add_child(enemy)
