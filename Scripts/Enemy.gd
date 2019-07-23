extends KinematicBody2D
class_name Enemy

var lives = 3
var flip_direction = false
var direction = Vector2()
var motion = Vector2()
var speed = 1500
var gravity = 1000

func _ready():
	$IdleTimer.connect("timeout", self, "_on_IdleTimer_timeout")
	$WalkTimer.connect("timeout", self, "_on_WalkTimer_timeout")
	$IdleTimer.start()

func _physics_process(delta):
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
	if lives != 0:
		$WalkTimer.start()
		$AnimationTree.set("parameters/conditions/idle", false)
		$AnimationTree.set("parameters/conditions/walk", true)
		flip_direction = !flip_direction

		if flip_direction:
			$Sprite.scale.x = -2
			direction.x = -1
		else:
			$Sprite.scale.x = 2
			direction.x = 1

func _on_WalkTimer_timeout():
	if lives != 0:
		direction.x = 0
		$IdleTimer.start()
		$AnimationTree.set("parameters/conditions/idle", true)
		$AnimationTree.set("parameters/conditions/walk", false)