extends CharacterBody2D

@export var speed = 500.0
@export var run_speed = 800.0
@export var jump_velocity = -500.0
@export var jump_start_velocity = -1100
@export var jump_height = 300
@export var jump_height_run_boost = 50
@export var gravity = 5000.0
@export var terminal_velocity = 2000
var _holding_jump = false
var _is_jumping = false
var _jump_potential = 0

func jump():
	_is_jumping = true
	_jump_potential = jump_height
	if velocity.x > speed or velocity.x < -speed:
		_jump_potential += jump_height_run_boost
	velocity.y = jump_start_velocity
	$AnimatedSprite2D.play("jump")
	
func jumping(delta):
	_jump_potential = _jump_potential + velocity.y*delta
	velocity.y = move_toward(velocity.y, jump_velocity, 5)
	
func move(dir, delta, is_running: bool = false, is_midair: bool = false):
	var target_speed = speed
	var speed_increment = 60
	if is_running: target_speed = run_speed
	if not is_midair: 
		speed_increment = 80
		if dir > 0: $AnimatedSprite2D.flip_h = true
		if dir < 0: $AnimatedSprite2D.flip_h = false
	if velocity.x * dir < 0: speed_increment + 20
	
	velocity.x = move_toward(velocity.x, dir*target_speed, speed_increment)

func _physics_process(delta):
	var dir := Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var is_running = Input.is_action_pressed("ui_down")
	
	$AnimatedSprite2D.speed_scale = 1
	
	if is_on_floor():
		if dir != 0:
			move(dir, delta, is_running)
			$AnimatedSprite2D.play("walk")
		else:
			velocity.x = move_toward(velocity.x, 0, 100)
			$AnimatedSprite2D.play("idle")
			
		#jump logic
		if Input.is_action_just_pressed("ui_accept"):
			jump()
	else:
		move(dir, delta, is_running, true)
		if not _is_jumping:
			velocity.y += gravity * delta
			velocity.y = min(velocity.y, terminal_velocity)
		elif Input.is_action_pressed("ui_accept") and _jump_potential > 0:
			jumping(delta)
		else:
			_jump_potential = 0
			_is_jumping = false
		if velocity.y > 0:
			$AnimatedSprite2D.speed_scale = 0.3 + (velocity.y / terminal_velocity)*0.7
			$AnimatedSprite2D.play("fall")
	move_and_slide()
