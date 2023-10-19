class_name Bullet
extends Area2D

signal target_hit

@export var speed := 500


func _process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("destroy"):
		body.destroy()
	target_hit.emit()
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
