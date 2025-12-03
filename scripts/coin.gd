extends Area2D

signal coin_collected
var collected: bool = false

@export var particle_emitter : PackedScene

func collect():
	if not collected:
		collected = true
		emit_signal("coin_collected")
		if particle_emitter: 
			var particles = particle_emitter.instantiate()
			particles.position.x = position.x
			particles.position.y = position.y
			get_parent().add_child(particles)
		position.y = 9999
		$SFXCoin.play()
		await $SFXCoin.finished
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	collect()

func _on_area_entered(area: Area2D) -> void:
	collect()
