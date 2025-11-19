extends StaticBody2D

var original_pos = position.y
@export var bounce_velocity = -900
@export var gravity = 5000
@export var spawn_scene : PackedScene
@export var total_uses = 1

var bouncing = false

var y_speed = 0.0

func _on_area_2d_area_entered(area: Area2D) -> void:
	if not bouncing && total_uses > 0:
		bounce()
	
func bounce():
	print("HIIII")
	bouncing = true
	y_speed = bounce_velocity
	total_uses -= 1
	if spawn_scene:
		$SFXPowerUpAppear.play()
		var spawned_entity = spawn_scene.instantiate()
		add_sibling(spawned_entity)
		spawned_entity.position.x = position.x
		spawned_entity.position.y = position.y-30
		spawned_entity.velocity.y = -1500
	

func _ready():
	original_pos = position.y

func _process(delta: float) -> void:
	if bouncing: 
		y_speed += gravity*delta
		position.y += y_speed*delta
		if position.y > original_pos: 
			bouncing = false
			position.y = original_pos
