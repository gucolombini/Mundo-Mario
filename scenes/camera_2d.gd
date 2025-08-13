extends Camera2D

@export var target: Node
var target_offset = 1000
var lerp_speed = 10

func _process(delta: float) -> void:
	if target:
		position.x = target.position.x
		position.y = target.position.y
