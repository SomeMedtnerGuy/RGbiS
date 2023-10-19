class_name Laser
extends ShapeCast2D


func _physics_process(_delta: float) -> void:
	for i in get_collision_count():
		var object = get_collider(i)
		if object and object.has_method("destroy"):
			object.call_deferred("destroy")
