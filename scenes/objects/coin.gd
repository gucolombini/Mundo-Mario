extends Area2D

signal coin_collected

func collect():
	emit_signal("coin_collected")
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	collect()

func _on_area_entered(area: Area2D) -> void:
	collect()
