extends KinematicBody2D

var velocity = Vector2.ZERO
var accell 

var target
var targetpos = Vector2.ZERO
var basespeed = 800
var speed = 0
var lifetime
var radius
var can_exp = false
func summon(pos, corruption, player, lif):
	#print(pos, corruption, player, lif)
	lifetime = lif
	$Node2D/life.wait_time = lifetime
	$Node2D/life.start()
	target = player
	global_position = pos
	radius = 225 + 75* corruption/8
	$Node2D/Tween.interpolate_property(self, 'speed', 0, basespeed + basespeed * corruption/24, 0.5, Tween.TRANS_CIRC, Tween.EASE_IN)
	$Node2D/Tween.start()
	$Node2D/arm_time.start(0.5)
	accell = (basespeed + basespeed * corruption/24)*4

func _physics_process(delta):
	velocity += accell * global_position.direction_to(target.get_global_position())* delta
	if velocity.length() > speed:
		velocity = velocity.normalized()*speed
	$Node2D.look_at(target.get_global_position())
	position = position + velocity * delta

func explode():
	set_physics_process(false)
	#print('explode2')
	speed = 0
	$Node2D/ex.emitting = true
	$Node2D/explode/CollisionShape2D.set_deferred('disabled', false)
	$CollisionShape2D.set_deferred('disabled', false)
	$Node2D/Tween2.interpolate_property($Node2D/explode/CollisionShape2D, 'scale', Vector2(1, 1), Vector2(radius/18,radius/18), 0.05,  Tween.TRANS_LINEAR)
	$Node2D/Tween2.start()
	$Node2D/Tween.interpolate_property($CollisionShape2D, 'scale', Vector2(1, 1), Vector2(radius/18,radius/18), 0.05,  Tween.TRANS_LINEAR)
	$Node2D/Tween.start()
	$Node2D/anim.play('explode')
	$Node2D/AnimatedSprite.visible = false
	$Node2D/Particles2D.visible = false


func _on_hurtbox_body_entered(body):
	if !body.is_in_group('projectile') && !body.is_in_group('explosion'):
		explode()


func armed():
	$Node2D/hurtbox/CollisionShape2D.set_deferred('disabled', false)
	can_exp = true
	$Node2D/anim.play('arm')


func _on_anim_animation_finished(anim_name):
	print(anim_name)
	if anim_name == 'explode':
		queue_free()
