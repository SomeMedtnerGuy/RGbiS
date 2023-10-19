extends Node2D

var current_weapon: Character.WEAPONS = Character.WEAPONS.BULLET

@onready var bullet: PathFollow2D = $Path2D/Bullet
@onready var bullet_spray: PathFollow2D = $Path2D/BulletSpray
@onready var laser: PathFollow2D = $Path2D/Laser

@onready var indicators := {
	Character.WEAPONS.BULLET: bullet, 
	Character.WEAPONS.BULLET_SPRAY: bullet_spray, 
	Character.WEAPONS.LASER: laser}


func switch_weapon(weapon: Character.WEAPONS):
	current_weapon = weapon
	var difference: float = 1.0 - indicators[weapon].progress_ratio
	for indicator in indicators.values():
		var target_value: float = indicator.progress_ratio + difference
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(indicator, "progress_ratio", target_value, 0.2)


