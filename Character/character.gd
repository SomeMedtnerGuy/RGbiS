class_name Character
extends RigidBody2D

signal bullet_fired(bullet: Bullet)
signal weapon_switched(weapon: WEAPONS)
signal input_missed

enum WEAPONS { BULLET, BULLET_SPRAY, LASER }

@export var player_index := 1

@export var bullet_scene: PackedScene

@export var thrust_strength := 1000
@export var torque := 30000

var active_weapon: WEAPONS = WEAPONS.BULLET

var input_allowed
var input_done := false

var size: Vector2

@onready var input_map := {
	move_forwards = "move_forwards{n}".format({"n": player_index}),
	move_backwards = "move_backwards{n}".format({"n": player_index}),
	rotate_left = "rotate_left{n}".format({"n": player_index}),
	rotate_right = "rotate_right{n}".format({"n": player_index}),
	fire = "fire{n}".format({"n": player_index}),
	switch = "switch{n}".format({"n": player_index})
}

@onready var sprite := $Sprite2D
@onready var movement_animations: AnimationPlayer = $MovementAnimations
@onready var gun_tip: Marker2D = $Sprite2D/GunTip
@onready var laser: ShapeCast2D = $Laser


func _ready():
	size = sprite.texture.get_size()


func _integrate_forces(state: PhysicsDirectBodyState2D):
	state.apply_force(Vector2())
	for action in input_map.values():
		if Input.is_action_just_pressed(action):
			_handle_movement_input(action, state)
			input_done = true


func _handle_movement_input(action: StringName, state: PhysicsDirectBodyState2D):
	if not input_allowed or input_done:
		pulse()
		input_missed.emit()
		return
	
	var rotation_direction = 0
	
	match action:
		input_map.move_forwards:
			var thrust = Vector2(thrust_strength, 0)
			movement_animations.play("move_forwards")
			state.apply_force(thrust.rotated(rotation))
		input_map.move_backwards:
			var thrust = Vector2(-thrust_strength, 0)
			movement_animations.play("move_backwards")
			state.apply_force(thrust.rotated(rotation))
		input_map.rotate_right:
			rotation_direction += 1
			movement_animations.play("rotate_right")
			state.apply_torque(rotation_direction * torque)
		input_map.rotate_left:
			rotation_direction -= 1
			movement_animations.play("rotate_left")
			state.apply_torque(rotation_direction * torque)
		input_map.fire:
			match active_weapon:
				WEAPONS.BULLET:
					fire_bullet()
				WEAPONS.BULLET_SPRAY:
					fire_bullet_spray()
				WEAPONS.LASER:
					fire_laser()
		input_map.switch:
			active_weapon = (active_weapon + 1) % WEAPONS.size()
			weapon_switched.emit(active_weapon)


func fire_bullet() -> void:
	var bullet := bullet_scene.instantiate() as Bullet
	bullet.rotation = rotation
	bullet.global_position = gun_tip.global_position
	bullet_fired.emit(bullet)


func fire_bullet_spray() -> void:
	for i in 4:
		fire_bullet()
		await get_tree().create_timer(0.42 / 4.0).timeout


func fire_laser() -> void:
	laser.show()
	laser.enabled = true
	await get_tree().create_timer(0.2).timeout
	laser.enabled = false
	laser.hide()


func pulse() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.1).from(Vector2(1.5, 1.5))


func destroy() -> void:
	queue_free()
