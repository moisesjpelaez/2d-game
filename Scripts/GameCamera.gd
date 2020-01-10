extends Camera2D

var shake_amount = 0

onready var timer : Timer = $Timer

func _ready() -> void:
	Global.connect("shake_screen", self, "shake_camera")

func _process(delta: float) -> void:
	offset_h = rand_range(-shake_amount, shake_amount)
	offset_v = rand_range(-shake_amount, shake_amount)
	
func shake_camera(amount, duration) -> void:
	shake_amount = amount
	timer.wait_time = duration
	timer.start()

func _on_Timer_timeout() -> void:
	shake_amount = 0
