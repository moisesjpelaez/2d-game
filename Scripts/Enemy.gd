extends KinematicBody2D
class_name Enemy

export(int) var lives : int = 3
export(int) var speed : int = 5000
export(int) var gravity : int = 700
export(int) var attack_distance : int = 35
export(Vector2) var hit_speed = Vector2(100, -200)
export(int) var attack_speed : int = 1500
export(bool) var hit : bool = false
export var attack_boost = false

var flip_direction = false
var direction = Vector2()
var motion = Vector2()
var hit_impulse = false
var dead = false

var is_close = false
var close_signal = false

onready var state_machine = $AnimationTree.get("parameters/playback")
onready var sprite : Sprite = $Sprite

func _ready():
	$AttackTimer.connect("timeout", self, "_on_AttackTimer_timeout")
	$Sprite/HitArea.connect("body_entered", self, "_on_HitArea_body_entered")

func _physics_process(delta):
	var current_state = state_machine.get_current_node()

	if !hit:
		if !dead:
			if abs(Global.player.global_position.x - global_position.x) > attack_distance:
				is_close = false
				close_signal = false
				flip_direction(global_position.x > Global.player.global_position.x)
				state_machine.travel("Walk")
			else:
				is_close = true
				direction.x = 0
				
				if is_close && !close_signal:
					close_signal = true
					state_machine.travel("Idle")
					_on_AttackTimer_timeout()
	else:
		is_close = false
		close_signal = false
		if "Idle" in current_state:
			hit = false
	
	if is_on_floor():
		if dead:
			add_collision_exception_with(Global.player)
			motion.x = 0
		else:
			motion.x = direction.x * speed * delta

		if hit_impulse:
			motion.x = 0
			motion = hit_speed
			motion.x *= -sign(sprite.scale.x)
			hit_impulse = false

	if "Attack" in current_state && !hit:
		motion.x = 0

	if attack_boost:
		flip_direction(global_position.x > Global.player.global_position.x)
		motion.x = direction.x * attack_speed
		attack_boost = false

	motion.y += gravity * delta
	move_and_slide(motion, Vector2(0, -1))

func get_damage():
	lives -= 1

func die():
	queue_free()

func flip_direction(flip):
	if flip:
		$Sprite.scale.x = -1
		direction.x = -1
	else:
		$Sprite.scale.x = 1
		direction.x = 1

func _on_AttackTimer_timeout():
	if is_close && close_signal:
		state_machine.travel("Attack")
		
		if !Global.game_is_over:
			$AttackTimer.start()

func get_hit():
	if !hit:
		hit_impulse = true
		hit = true
		state_machine.stop()
		if lives > 0:
			state_machine.start("Hit")
		elif lives <= 0:
			dead = true
			state_machine.start("Die")

func _on_HitArea_body_entered(body):
	if body is Player:
		body.get_hit()

func freeze_frame(time):
	OS.delay_msec(time)
