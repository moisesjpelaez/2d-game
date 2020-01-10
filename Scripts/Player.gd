extends KinematicBody2D
class_name Player

export(int) var gravity : int = 512
export(int) var max_speed : int = 64
export(int) var acceletation : int = 512
export(float) var friction : float = 0.3
export(int) var jump_speed : int = 128
export(int) var attack_speed = 1024
export(int) var air_combo_speed = 2048
export(bool) var hit : bool = false
export(int) var sprite_scale : int = 2

var motion = Vector2.ZERO
var landed = false
var attack_impulse = false

onready var state_machine : AnimationNodeStateMachine = $AnimationTree.get("parameters/playback")
onready var landing_sound : AudioStreamPlayer2D = $Sounds/Land
onready var jump_sound : AudioStreamPlayer2D = $Sounds/Jump
onready var hit_sound : AudioStreamPlayer2D = $Sounds/Hit
onready var stomp_sound : AudioStreamPlayer2D = $Sounds/Stomp

func _ready():
	Global.player = self
	$Sprite/HitArea.connect("body_entered", self, "_on_HitArea_body_entered")
	$Sprite/AirComboArea.connect("body_entered", self, "_on_AirComboArea_body_entered")

func _physics_process(delta):
	var current_state = state_machine.get_current_node()
	var input_direction : float = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	if !("Combo" in current_state):
		$Sprite/HitArea/CollisionShape2D.set_deferred("disabled", true)

	if hit:
		$Sprite/HitArea/CollisionShape2D.set_deferred("disabled", true)
		return
	
	if !Global.game_started:
		if is_on_floor():
			if !landed:
				landed = true
				landing_sound.play()
	
			motion.y = 10

		motion.x = 0
		motion.y += gravity * delta
		move_and_slide(motion, Vector2(0, -1))
		return

	if input_direction != 0:
		$Sprite.scale.x = sign(input_direction)
		motion.x += input_direction * acceletation * delta
		motion.x = clamp(motion.x, -max_speed, max_speed)
	else:
		motion.x = lerp(motion.x, 0, friction)

	if is_on_floor():
		if is_on_floor():
			if !landed:
				landed = true
				landing_sound.play()
	
			motion.y = 10
			
			if "AirComboLoop" in current_state:
				state_machine.start("AirComboEnd")
				Global.emit_signal("shake_screen", 0.7, 0.35)
				stomp_sound.play()
				
		if !("Combo" in current_state):
			if input_direction != 0:
				state_machine.travel("Run")
			if input_direction == 0:
				state_machine.travel("Idle")

		if Input.is_action_just_pressed("jump"):
			jump_sound.play()
			state_machine.travel("Jump")
			motion.y = -jump_speed

		if Input.is_action_just_pressed("attack"):
			match current_state:
				"Combo1":
					state_machine.travel("Combo2")
				"Combo2":
					state_machine.travel("Combo3")
				_:
					state_machine.travel("Combo1")
	else:
		if Input.is_action_just_pressed("attack"):
			if !("AirCombo" in current_state):
				motion.y = -jump_speed
				state_machine.stop()
				state_machine.start("AirComboStart")

		landed = false
	
	if "Combo" in current_state:
		if attack_impulse:
			motion.x = attack_speed * sign($Sprite.scale.x) * delta
			attack_impulse = false
		else:
			motion.x = 0
	
	if !("AirCombo" in current_state):
		motion.y += gravity * delta
	else: 
		motion.y += air_combo_speed * delta
		
	move_and_slide(motion, Vector2(0, -1))

func attack_motion():
	attack_impulse = true

func get_hit():
	if Global.game_is_over:
		return

	hit = true
	state_machine.stop()
	if Global.player_lives > 0:
		state_machine.start("Hit")
	elif Global.player_lives == 0:
		state_machine.start("Die")

func get_damage():
	Global.emit_signal("shake_screen", 0.25, 0.5)
	hit_sound.play()

	if Global.player_lives > 0:
		Global.ui_health.get_child(Global.player_lives).texture = Global.heart_texture
		Global.player_lives -= 1
	else:
		Global.game_over()

func _on_HitArea_body_entered(body):
	if body.is_in_group("Enemies"):
		body.get_hit(1)
		
func _on_AirComboArea_body_entered(body):
	if body.is_in_group("Enemies"):
		body.get_hit(5)
		