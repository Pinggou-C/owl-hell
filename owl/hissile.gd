extends KinematicBody2D

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO
var rng = RandomNumberGenerator.new()
var target
var targetpos = Vector2.ZERO
var basespeed = 800
var speed = 750.0
export var steer_force = 40.0
var lifetime
var radius
var speedmod = 1.0
var can_exp = false
func summon(pos, corruption, player, lif):
	#print(pos, corruption, player, lif)
	lifetime = lif /0.3
	$Node2D/life.wait_time = lifetime
	$Node2D/life.start()
	target = player
	global_position = pos
	radius = 150 + 75* corruption/8
	$Node2D/Tween.interpolate_property(self, 'speedmod', 0.0, 1.0 + 1.0 * corruption/24.0, 0.5, Tween.TRANS_CIRC, Tween.EASE_IN)
	$Node2D/Tween.start()
	$Node2D/arm_time.start(0.5)
	look_at(target.get_global_position())
	steer_force = (60.0 + 60.0 * corruption/24.0)
	velocity = transform.x * speed * speedmod
	rotation += rand_range(-0.25, 0.25)


func seek():
	var steer = Vector2.ZERO
	if target:
		var desired = ((target.position - position)*rng.randf_range(0.5, 2.0)).normalized() * speed  #* speedmod
		steer = (desired - velocity).normalized() * steer_force
	return steer

func _physics_process(delta):
	acceleration += seek()
	velocity += acceleration * delta
	velocity = velocity.clamped(speed)
	rotation = velocity.angle()
	position += velocity * delta #* speedmod





#func _physics_process(delta):
	#velocity += accell * global_position.direction_to(target.get_global_position())* delta
#	if velocity.length() > speed:
	#	velocity = velocity.normalized()*speed
	#var goal = global_position.angle_to_point(target.get_global_position())
	#print(goal, rotation)
	#if rotation > goal:
	#	rotate(-acceleration*delta)
	#else:
	#	rotate(acceleration*delta)
	#print(acceleration*delta)
	#rotation = goal + PI
	#var dir = Vector2(cos(rotation*PI), sin(rotation*PI))
	#print(dir)
	#position += transform.x * -speed * delta / 3.0

func explode():
	set_physics_process(false)
	controller.shake(0.6, 0.8)
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
		if body.is_in_group('trueplayer'):
			controller._freeze_frame(0, 0.075)
		if body.is_in_group('owl'):
			controller._freeze_frame(0, 0.1)
		
		explode()


func armed():
	$Node2D/hurtbox/CollisionShape2D.set_deferred('disabled', false)
	can_exp = true
	$Node2D/anim.play('arm')


func _on_anim_animation_finished(anim_name):
	#print(anim_name)
	if anim_name == 'explode':
		queue_free()

func hit():
	explode()









