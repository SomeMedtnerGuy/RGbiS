class_name DestructionParticles
extends CPUParticles2D


func _ready() -> void:
	set_emitting(true)


func _physics_process(_delta: float) -> void:
	if not emitting:
		queue_free()
