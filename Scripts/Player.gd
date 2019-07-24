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
var lives = 3
export var hit = false

func _ready():
	Global.player = self
	$Sprite/HitArea.connect("body_entered", self, "_on_HitArea_body_entered")

func _physics_process(delta):
	if hit:
		$Sprite/HitArea/CollisionShape2D.set_deferred("disabled", true)
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
		
		if $Sprite/AnimationPlayer.current_animation != "GroundAttack":
			if direction.x != 0:
				$Sprite/AnimationPlayer.play("Run")
			else:
				$Sprite/AnimationPlayer.play("Idle")

			if Input.is_action_just_pressed("jump"):
				$Jump.play()
				$Sprite/AnimationPlayer.play("Jump")
				motion.y = -jump_speed
		
		if Input.is_action_just_pressed("attack"):
			$Sprite/AnimationPlayer.play("GroundAttack")
	else:
		if Input.is_action_just_pressed("attack"):
			$Sprite/AnimationPlayer.play("JumpAttack")

		landed = false
	
	if $Sprite/AnimationPlayer.current_animation == "GroundAttack":
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

func play_audio(audio_node):
	get_node(audio_node).play()

func _on_HitArea_body_entered(body):
	if body is Enemy:
		if body.lives > 0:
			body.get_node("AnimationTree").get("parameters/playback").travel("Hit")
		elif body.lives == 0:
			body.get_node("AnimationTree").get("parameters/playback").travel("Die")

func get_damage():
	$Hit.play()

	if lives > 0:
		lives -= 1
	else:
		Global.game_over = true