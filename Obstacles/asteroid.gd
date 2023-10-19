class_name Asteroid
extends RigidBody2D

signal broken_down

enum SIZES { SMALL, MEDIUM, LARGE }

const SIZE_REGIONS:= {
	SIZES.SMALL: [Rect2(0, 0, 16, 16), Rect2(0, 16, 16, 16), Rect2(0, 32, 16, 16)],
	SIZES.MEDIUM: [Rect2(0, 0, 32, 32), Rect2(0, 32, 32, 32), Rect2(0, 64, 32, 32)],
	SIZES.LARGE: [Rect2(0, 0, 64, 64), Rect2(0, 64, 64, 64), Rect2(0, 128, 64, 64)]
}

@export var size: SIZES = SIZES.SMALL

var _impulse_strength: float
var _torque: float

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func setup(specs: Dictionary) -> void:
	
	position = specs.spawn_pos
	rotation = specs.rotation
	_impulse_strength = specs.impulse_strength
	_torque = specs.torque


func _ready() -> void:
	var sprite_choices: Array = SIZE_REGIONS[size]
	sprite_2d.region_rect = sprite_choices[randi() % len(sprite_choices)]
	# Mass is only taken into account on the second physics frame (bug?), so waiting for it is necessary
	for _i in 2:
		await get_tree().physics_frame
	apply_initial_forces()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func destroy() -> void:
	set_visible(false)
	collision_shape_2d.set_deferred("disabled", true)
	if size >= SIZES.SMALL:
		broken_down.emit(size, global_position)
	var particles: CPUParticles2D = load("res://Obstacles/destruction_particles.tscn").instantiate()
	particles.global_position = global_position
	particles.emission_sphere_radius = collision_shape_2d.shape.radius
	get_parent().add_child(particles)
	queue_free()


func _on_body_entered(body: Node) -> void:
	if body.has_method("destroy"):
		body.destroy()


func apply_initial_forces() -> void:
	apply_impulse(Vector2.RIGHT.rotated(rotation) * _impulse_strength)
	apply_torque(_torque)


