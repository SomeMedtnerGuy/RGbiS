extends Node2D

const INPUT_ALLOWED_COLOR := Color(0, 1, 0)
const INPUT_DISALLOWED_COLOR := Color(1, 0, 0)

@onready var synchronizer := $Synchronizer
@onready var characters := $Characters
@onready var asteroid_spawner: AsteroidSpawner = $AsteroidSpawner
@onready var asteroids: Node2D = $Asteroids
@onready var projectiles: Node2D = $Projectiles
@onready var weapon_indicator: Node2D = $UI/WeaponIndicator
@onready var score_label: Label = $UI/ScoreLabel
@onready var character: RigidBody2D = $Characters/Character

var score := 0

func _ready():
	synchronizer.connect("input_allowed_changed", _on_Synchronizer_input_allowed_changed)
	asteroid_spawner.start_random_spawning()


## Takes care of all changes regarding what should happen when the state of input permission changes
func _on_Synchronizer_input_allowed_changed(value) -> void:
	for character in characters.get_children():
		# Directly controls input based on input_window
		character.input_allowed = value
		# Resets to false the input_done flag whenever the input_window starts
		character.input_done = not value
	if value:
		modulate = INPUT_ALLOWED_COLOR
	else:
		modulate = INPUT_DISALLOWED_COLOR


func _on_asteroid_spawner_asteroid_spawned(asteroid: Asteroid) -> void:
	asteroids.call_deferred("add_child", asteroid)


func _on_character_bullet_fired(bullet: Bullet) -> void:
	projectiles.call_deferred("add_child", bullet)
	bullet.target_hit.connect(_on_bullet_target_hit)


func _on_character_weapon_switched(weapon: Character.WEAPONS) -> void:
	weapon_indicator.switch_weapon(weapon)


func _on_bullet_target_hit() -> void:
	if character.active_weapon == Character.WEAPONS.BULLET:
		score += 5
	else:
		score += 1
	score_label.text = str(score)


func _on_character_input_missed() -> void:
	score = max(score - 10, 0)
	score_label.text = str(score)

