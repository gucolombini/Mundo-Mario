extends StaticBody2D

var original_pos = position.y
@export var bounce_velocity = -900
@export var gravity = 5000

var bouncing = false

var y_speed = 0.0

func _on_area_2d_area_entered(area: Area2D) -> void:
	if not bouncing:
		bounce()
	
func bounce():
	print("HIIII")
	bouncing = true
	y_speed = bounce_velocity
	

func _ready():
	original_pos = position.y

func _process(delta: float) -> void:
	if bouncing: 
		y_speed += gravity*delta
		position.y += y_speed*delta
		if position.y > original_pos: 
			bouncing = false
			position.y = original_pos
