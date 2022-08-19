extends Node2D

var rng = RandomNumberGenerator.new()
var named = "shortbow"
var delay = 0.2
onready var projectile = preload("res://player/weapons/projectile.tscn")
var projectile_speed = 60000
var projectile_damage = 10
var player = null
var aimrand = 0.1

func _onready():
	player = get_parent().get_parent()

func attack(mousepos):
		rng.randomize()
		var prot = projectile.instance()
		player.get_parent().add_child(prot)
		prot.look_at(get_global_mouse_position())
		prot.position = $center.get_global_position()
		var rand = global_position.direction_to(get_global_mouse_position())
		prot.summon(projectile_speed,  Vector2(rand.x +rng.randf_range(-1 * aimrand,1*aimrand),rand.y + rng.randf_range(-1 * aimrand,1*aimrand)).normalized() , projectile_damage, player.velocity)
