extends KinematicBody2D
class_name Player

var gravity = 1000
var speed = 20000
var jump_speed = 500
var direction = Vector2()
var motion = Vector2()
var landed = false
var attack_impulse = false
var attack_speed = 100000
export var hit = false

var state_machine

func _ready():
	Global.player = self
	$Sprite/HitArea.connect("body_entered", self, "_on_HitArea_body_entered")
	state_machine = $AnimationTree.get("parameters/playback")

func _physics_process(delta):
	var current_state = state_machine.get_current_node()

	if hit:
		$Sprite/HitArea/CollisionShape2D.set_deferred("disabled", true)
		return
	
	if !Global.game_started:
		if is_on_floor():
			if !landed:
				landed = true
				$Land.play()
	
			motion.y = 10

		motion.x = 0
		motion.y += gravity * delta
		move_and_slide(motion, Vector2(0, -1))
		return

	if Input.is_action_pressed("move_left"):
		$Sprite.scale.x = -2
		direction.x = -1
	elif Input.is_action_pressed("move_right"):
		$Sprite.scale.x = 2
		direction.x = 1
	else:
		direction.x = 0
	
	motion.x = direction.x * speed * delta

	if is_on_floor():
		if !landed:
			landed = true
			$Land.play()

		motion.y = 10

		if Input.is_action_just_pressed("attack"):
			state_machine.travel("Combo1")
		
		if current_state != "Combo1":
			if direction.x != 0:
				state_machine.travel("Run")
			if direction.x == 0:
				state_machine.travel("Idle")

			if Input.is_action_just_pressed("jump"):
				$Jump.play()
				state_machine.travel("Jump")
				motion.y = -jump_speed
	else:
		landed = false
	
	if $Sprite/AnimationPlayer.current_animation == "Combo1":
		if attack_impulse:
			if $Sprite.scale.x == -2:
				motion.x = -attack_speed * delta
			else:
				motion.x = attack_speed * delta
			attack_impulse = false
		else:
			motion.x = 0

	motion.y += gravity * delta
	move_and_slide(motion, Vector2(0, -1))

func attack_motion():
	attack_impulse = true

func get_hit():
	hit = true
	if Global.player_lives > 0:
		state_machine.travel("Hit")
	elif Global.player_lives == 0:
		state_machine.travel("Die")

func get_damage():
	$Hit.play()

	if Global.player_lives > 0:
		Global.ui_health.get_child(Global.player_lives).texture = Global.heart_texture
		Global.player_lives -= 1
	else:
		Global.game_over()

func _on_HitArea_body_entered(body):
	if body.is_in_group("Enemies"):
		body.get_hit()
