extends KinematicBody2D
class_name Enemy

var lives = 3
var flip_direction = false
var direction = Vector2()
var motion = Vector2()
var speed = 1500
var gravity = 1000

var follow_player = false
var reset_timer = false
var attack_player = false
var detection_distance = 350
var attack_distance = 55

func _ready():
	$IdleTimer.connect("timeout", self, "_on_IdleTimer_timeout")
	$WalkTimer.connect("timeout", self, "_on_WalkTimer_timeout")
	$AttackTimer.connect("timeout", self, "_on_AttackTimer_timeout")
	$Sprite/HitArea.connect("body_entered", self, "_on_HitArea_body_entered")
	$IdleTimer.start()

func _physics_process(delta):
	follow_player = abs(global_position.x - Global.player.global_position.x) < detection_distance

	if follow_player:
		reset_timer = false

		if abs(global_position.x - Global.player.global_position.x) < attack_distance:
			direction.x = 0

			if !attack_player:
				attack_player = true
				$AttackTimer.start()
			else:
				$AnimationTree.set("parameters/conditions/idle", true)
				$AnimationTree.set("parameters/conditions/walk", false)
				$AnimationTree.set("parameters/conditions/attack", false)
		else:
			$AnimationTree.set("parameters/conditions/idle", false)
			$AnimationTree.set("parameters/conditions/walk", true)
			$AnimationTree.set("parameters/conditions/attack", false)

			if global_position.x < Global.player.global_position.x:
				$Sprite.scale.x = 2
				direction.x = 1
			elif global_position.x > Global.player.global_position.x:
				$Sprite.scale.x = -2
				direction.x = -1
			else:
				direction.x = 0
	else:
		if !reset_timer:
			reset_timer = true
			$AnimationTree.set("parameters/conditions/idle", true)
			$AnimationTree.set("parameters/conditions/walk", false)
			$AnimationTree.set("parameters/conditions/attack", false)
			direction.x = 0
			$IdleTimer.start()

	if !$CollisionShape2D.disabled:
		motion.x = direction.x * speed * delta

		if is_on_floor():
			motion.y = 10
		
		motion.y += gravity * delta
		move_and_slide(motion, Vector2(0, -1))

func get_damage():
	lives -= 1

func die():
	queue_free()

func _on_IdleTimer_timeout():
	if lives != 0 && !follow_player:
		$WalkTimer.start()
		$AnimationTree.set("parameters/conditions/idle", false)
		$AnimationTree.set("parameters/conditions/walk", true)
		$AnimationTree.set("parameters/conditions/attack", false)
		flip_direction = !flip_direction

		if flip_direction:
			$Sprite.scale.x = -2
			direction.x = -1
		else:
			$Sprite.scale.x = 2
			direction.x = 1

func _on_WalkTimer_timeout():
	if lives != 0 && !follow_player:
		direction.x = 0
		$IdleTimer.start()
		$AnimationTree.set("parameters/conditions/idle", true)
		$AnimationTree.set("parameters/conditions/walk", false)
		$AnimationTree.set("parameters/conditions/attack", false)

func _on_AttackTimer_timeout():
	attack_player = false
	$AnimationTree.set("parameters/conditions/idle", false)
	$AnimationTree.set("parameters/conditions/attack", true)
	$AnimationTree.set("parameters/conditions/walk", false)

func _on_HitArea_body_entered(body):
	if body is Player:
		body.get_damage()
