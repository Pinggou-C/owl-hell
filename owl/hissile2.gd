extends KinematicBody2D

var velocity = Vector2.ZERO
var accell 

var target
var basespeed = 2000
var speed
var lifetime
var radius
var can_exp = false
func summon(pos, corruption, player, lif):
	lifetime = null
	$life.wait_time = lifetime
	$life.start()
	target = player
	global_position = pos
	radius = 200 + 100* corruption/8
	$Tween.interpolate_property(self, 'speed', 0, basespeed + basespeed * corruption/24, 0.5, Tween.TRANS_CIRC, Tween.EASE_IN)
	$Tween.start()
	$arm_timer.start(0.5)
	accell = speed*3


func explode():
	pass # Replace with function body.
	#position += velocity * delta


func _on_hurtbox_body_entered(body):
	if !body.is_in_group('projectile'):
		explode()
		speed = 0


func armed():
	can_exp = true
