extends Area2D

signal coin_collected
var collected: bool = false

func collect():
	if not collected:
		collected = true
		emit_signal("coin_collected")
		position.y = 9999
		$SFXCoin.play()
		await $SFXCoin.finished
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	collect()

func _on_area_entered(area: Area2D) -> void:
	collect()
