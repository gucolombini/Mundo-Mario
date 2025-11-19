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
const BASE_DUST_AMOUNT_RUN = 5
const BASE_DUST_AMOUNT_SKID = 20
const BASE_DUST_AMOUNT_JUMP = 5

#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite = $Visuals/AnimatedSprite2D
@onready var speed_bar = $ProgressBar
@onready var dust_emitter = $DustEmitter
@onready var skid_dust_emitter = $DustEmitter

enum States {IDLE, WALKING, RUNNING, SKIDDING, JUMPING, FALLING, STOMPING}
var animstate = "idle"
var p_meter = 0
var skidding = false

@export var jump_dust_emitter : PackedScene

func jump(jump_speed):
	velocity.y = jump_speed
	$SFXJump.play()
	animstate = "jump"
	if jump_dust_emitter: 
		var jump_dust = jump_dust_emitter.instantiate()
		jump_dust.position.x = position.x
		jump_dust.position.y = position.y
		get_parent().add_child(jump_dust)
	
func is_skidding():
	if abs(velocity.x) > BASE_SPEED/2 and is_on_floor(): return true
	else: return false
	
func toggle_ray_foot(value:bool = true) -> void:
	$FootRay.disabled = !value
	$FootRay2.disabled = !value

func _ready() -> void:
	speed_bar.value = 0
	speed_bar.max_value = BASE_P_METER_CHARGE_TIME 

func _physics_process(delta: float) -> void:
	var grounded = is_on_floor()
	var animation_timer = 1
	
	dust_emitter.emitting = false
	skid_dust_emitter.emitting = false
	
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
			if is_skidding(): skidding = true
		else: skidding = false
		velocity.x = move_toward(velocity.x, speed*dir, accel*delta)
		if grounded: $Visuals.scale.x = abs($Visuals.scale.x)*-dir
	elif grounded:
		velocity.x = move_toward(velocity.x, 0, BASE_DECCELERATION*delta)
	
	var gravity = BASE_GRAVITY
	if grounded and velocity.y == 0:
		gravity = 0
		if velocity.x != 0:
			if skidding:
				animstate = "skid"
				skid_dust_emitter.emitting = true
				skid_dust_emitter.amount = BASE_DUST_AMOUNT_SKID
			else: 
				animstate = "walk"
				animation_timer = 0.5 + (abs(velocity.x)/BASE_SPEED)/2
		else: 
			animstate = "idle"
		if abs(velocity.x) >= BASE_SPEED_RUN:
			animstate = "run"
			p_meter = move_toward(p_meter, BASE_P_METER_CHARGE_TIME , 60*delta)
			if p_meter >= BASE_P_METER_CHARGE_TIME: p_meter = BASE_P_METER_CHARGE_TIME+10
			dust_emitter.emitting = true
			dust_emitter.amount = BASE_DUST_AMOUNT_RUN
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
	
	var prevanimstate = sprite.animation
	if prevanimstate != animstate:
		var startframe = 0
		var frameprog = 0
		if prevanimstate == "run" and animstate == "walk" or prevanimstate == "walk" and animstate == "run":
			startframe = sprite.frame
			frameprog = sprite.frame_progress
		sprite.play(animstate)
		sprite.set_frame_and_progress(startframe, frameprog)
	sprite.speed_scale = animation_timer
	move_and_slide()

func _on_area_2d_foot_area_entered(area: Area2D) -> void:
	if not velocity.y < 0:
		print("STOMP!")
		if Input.is_action_pressed("jump"):
			jump(BASE_JUMP_SPEED + BASE_JUMP_SPEED_INC * (BASE_SPEED_P - BASE_SPEED))
		else:
			jump(BASE_STOMP_BOUNCE_SPEED)
	pass # Replace with function body.
