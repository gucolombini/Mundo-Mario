extends CharacterBody2D

const BASE_SPEED = 550.0
const BASE_SPEED_RUN = 1000.0
const BASE_SPEED_P = 1100.0
const BASE_ACCELERATION = 30
const BASE_DECCELERATION = 50
const BASE_JUMP_SPEED = -1700.0
const BASE_JUMP_SPEED_INC = -0.45
const BASE_GRAVITY = 7000
const BASE_GRAVITY_JUMP_HELD = BASE_GRAVITY/2
const BASE_MAX_FALL_SPEED = 3000
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var animstate = "idle"

func _physics_process(delta: float) -> void:
	var animation_timer = 1
	
	var dir := int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	if dir != 0:
		var accel = BASE_ACCELERATION
		var speed = BASE_SPEED
		if Input.is_action_pressed("ui_down"): speed = BASE_SPEED_RUN
		if velocity.x*dir < 0: accel = BASE_DECCELERATION
		velocity.x = move_toward(velocity.x, speed*dir, accel)
		if is_on_floor(): $AnimatedSprite2D.flip_h = dir == 1
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, BASE_DECCELERATION)
		
	if is_on_floor():
		if velocity.x != 0:
			animstate = "walk"
			animation_timer = 0.5 + (abs(velocity.x)/BASE_SPEED)/2
		else: 
			animstate = "idle"
	
	
	var jump_speed = BASE_JUMP_SPEED
	if abs(velocity.x) > BASE_SPEED:
		jump_speed += BASE_JUMP_SPEED_INC * (abs(velocity.x) - BASE_SPEED)
	var gravity = BASE_GRAVITY
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_speed
		animstate = "jump"
	if Input.is_action_pressed("ui_accept"):
		gravity = BASE_GRAVITY_JUMP_HELD
	if velocity.y > 0 and not is_on_floor():
		animstate = "fall"
		animation_timer = velocity.y*2/BASE_MAX_FALL_SPEED
	
	
	velocity.y = min(velocity.y + gravity * delta, BASE_MAX_FALL_SPEED)
	
	
	if $AnimatedSprite2D.animation != animstate:
		$AnimatedSprite2D.play(animstate)
	$AnimatedSprite2D.speed_scale = animation_timer
	move_and_slide()
