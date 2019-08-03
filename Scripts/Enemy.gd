extends KinematicBody2D
class_name Enemy

export var lives = 3
var flip_direction = false
var direction = Vector2()
var motion = Vector2()
var speed = 10000
var gravity = 1000
var attack_distance = 55
var state_machine
export var hit = false

func _ready():
	state_machine = $AnimationTree.get("parameters/playback")

	$IdleTimer.connect("timeout", self, "_on_IdleTimer_timeout")
	$WalkTimer.connect("timeout", self, "_on_WalkTimer_timeout")
	$AttackTimer.connect("timeout", self, "_on_AttackTimer_timeout")

	$Sprite/HitArea.connect("body_entered", self, "_on_HitArea_body_entered")

func _physics_process(delta):
	var current_state = state_machine.get_current_node()
		
	if "Idle" in current_state:
		hit = false

	if abs(Global.player.global_position.x - global_position.x) > attack_distance:
		flip_direction(global_position.x > Global.player.global_position.x)
	else:
		direction.x = 0
	
	motion.x = direction.x * speed * delta
	motion.y += gravity * delta
	move_and_slide(motion, Vector2(0, -1))

func get_damage():
	lives -= 1

func die():
	queue_free()

func flip_direction(flip):
	if flip:
		$Sprite.scale.x = -2
		direction.x = -1
	else:
		$Sprite.scale.x = 2
		direction.x = 1

func _on_IdleTimer_timeout():
	pass

func _on_WalkTimer_timeout():
	pass

func _on_AttackTimer_timeout():
	pass

func get_hit():
	if !hit:
		hit = true
		if lives > 0:
			state_machine.travel("Hit")
		elif lives <= 0:
			state_machine.travel("Die")

func _on_HitArea_body_entered(body):
	if body is Player:
		body.get_hit()
