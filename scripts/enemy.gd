extends CharacterBody2D

const BASE_GRAVITY = 7000
@export var speed = 15000

func _physics_process(delta: float) -> void:
	var gravity = BASE_GRAVITY
	var grounded = is_on_floor()
	if grounded: 
		velocity.x = speed * delta
	else: velocity.y = velocity.y + gravity * delta
	move_and_slide()
