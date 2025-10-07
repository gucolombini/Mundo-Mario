extends CharacterBody2D

const BASE_SPEED = 550.0
const BASE_SPEED_RUN = 1000.0
const BASE_SPEED_P = 1200.0
const BASE_ACCELERATION = 1800
const BASE_DECCELERATION = 2400
const BASE_JUMP_SPEED = -1950.0
const BASE_JUMP_SPEED_INC = -0.5
const BASE_STOMP_BOUNCE_SPEED = -1400
const BASE_GRAVITY = 8000
const BASE_GRAVITY_JUMP_HELD = BASE_GRAVITY/2
const BASE_MAX_FALL_SPEED = 2000
const BASE_P_METER_CHARGE_TIME  = 30
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var speed_bar = $ProgressBar
var animstate = "idle"
var p_meter = 0
var skidding = false

func jump(jump_speed):
	velocity.y = jump_speed
	$SFXJump.play()
	animstate = "jump"

func _ready() -> void:
	speed_bar.value = 0
	speed_bar.max_value = BASE_P_METER_CHARGE_TIME 

func _physics_process(delta: float) -> void:
	var grounded = is_on_floor()
	$HeadRayFront.disabled = grounded
	$HeadRayBack.disabled = grounded
	
	var animation_timer = 1
	
	speed_bar.value = p_meter
		
	var dir := int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	if dir != 0:
		var accel = BASE_ACCELERATION
		var speed = BASE_SPEED
		if Input.is_action_pressed("run"): 
			if p_meter >= BASE_P_METER_CHARGE_TIME : 
				speed = BASE_SPEED_P
			else: 
				speed = BASE_SPEED_RUN
		if velocity.x*dir < 0: 
			accel = BASE_DECCELERATION
			if abs(velocity.x) > BASE_SPEED/2: skidding = true
		else: skidding = false
		velocity.x = move_toward(velocity.x, speed*dir, accel*delta)
		if grounded: $AnimatedSprite2D.scale.x = -dir
	elif grounded:
		velocity.x = move_toward(velocity.x, 0, BASE_DECCELERATION*delta)
	
	var gravity = BASE_GRAVITY
	if grounded:
		gravity = 0
		if velocity.x != 0:
			if skidding:
				animstate = "skid"
			else: 
				animstate = "walk"
				animation_timer = 0.5 + (abs(velocity.x)/BASE_SPEED)/2
		else: 
			animstate = "idle"
		if abs(velocity.x) >= BASE_SPEED_RUN:
			p_meter = move_toward(p_meter, BASE_P_METER_CHARGE_TIME , 60*delta)
			if p_meter >= BASE_P_METER_CHARGE_TIME: p_meter = BASE_P_METER_CHARGE_TIME+10
		else:
			p_meter = move_toward(p_meter, 0, 60*delta)
	
	var jump_speed = BASE_JUMP_SPEED
	if abs(velocity.x) > BASE_SPEED:
		jump_speed += BASE_JUMP_SPEED_INC * (abs(velocity.x) - BASE_SPEED)
	if Input.is_action_just_pressed("jump") and grounded:
		jump(jump_speed)
	if Input.is_action_pressed("jump"):
		gravity = BASE_GRAVITY_JUMP_HELD
	if velocity.y > 0 and not grounded:
		animstate = "fall"
		animation_timer = velocity.y*2/BASE_MAX_FALL_SPEED
	
	velocity.y = min(velocity.y + gravity * delta, BASE_MAX_FALL_SPEED)
	
	if $AnimatedSprite2D.animation != animstate:
		$AnimatedSprite2D.play(animstate)
	$AnimatedSprite2D.speed_scale = animation_timer
	move_and_slide()

func _on_area_2d_foot_area_entered(area: Area2D) -> void:
	if not velocity.y < 0:
		print("STOMP!")
		if Input.is_action_pressed("jump"):
			jump(BASE_JUMP_SPEED + BASE_JUMP_SPEED_INC * (BASE_SPEED_P - BASE_SPEED))
		else:
			jump(BASE_STOMP_BOUNCE_SPEED)
	pass # Replace with function body.
