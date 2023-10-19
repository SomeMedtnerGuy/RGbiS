class_name AsteroidSpawner
extends Path2D

signal asteroid_spawned(asteroid: Asteroid)

const MIN_IMPULSE := 100.0
const MAX_IMPULSE := 150.0
const MIN_TORQUE := 4000.0
const MAX_TORQUE := 5000.0

@export var asteroid_small_scene: PackedScene
@export var asteroid_medium_scene: PackedScene
@export var asteroid_large_scene: PackedScene


@onready var asteroid_choices := [asteroid_small_scene, asteroid_medium_scene, asteroid_large_scene]
@onready var spawn_position: PathFollow2D = $SpawnPosition
@onready var spawn_timer: Timer = $SpawnTimer


func start_random_spawning() -> void:
	spawn_timer.start()


func _on_spawn_timer_timeout() -> void:
	spawn_position.progress_ratio = randf()
	var asteroid_scene = asteroid_choices[randi() % len(asteroid_choices)]
	var asteroid_specs := {
		"scene": asteroid_scene,
		"spawn_pos": spawn_position.global_position,
		"impulse_strength": randf_range(MIN_IMPULSE, MAX_IMPULSE),
		"rotation": spawn_position.rotation + PI/2 + randf_range(-PI/4, PI/4),
		"torque": randf_range(MIN_TORQUE, MAX_TORQUE)
	}
	spawn_asteroid(asteroid_specs)


func _on_asteroid_broken_down(size: Asteroid.SIZES, pos: Vector2) -> void:
	if size == Asteroid.SIZES.SMALL:
		return
	var asteroids_amount: int = int(clamp(randfn(3, 1.2), 0, 6))
	var rotation_amplitude := (2*PI) / asteroids_amount
	for i in asteroids_amount:
		var ast_rotation := rotation_amplitude * i + (randf_range(0, rotation_amplitude))
		var ast_pos := pos + (Vector2.RIGHT.rotated(ast_rotation) * 32.0 * size)
		var asteroid_specs := {
			"scene": asteroid_choices[size - 1],
			"spawn_pos": ast_pos,
			"impulse_strength": randf_range(MIN_IMPULSE, MAX_IMPULSE),
			"rotation": ast_rotation,
			"torque": randf_range(MIN_TORQUE, MAX_TORQUE)
		}
		spawn_asteroid(asteroid_specs)


func spawn_asteroid(specs: Dictionary) -> void:
	var asteroid = specs.scene.instantiate() as Asteroid
	asteroid.setup(specs)
	asteroid.broken_down.connect(_on_asteroid_broken_down)
	asteroid_spawned.emit(asteroid)
