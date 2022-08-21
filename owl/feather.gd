extends KinematicBody2D
export(int) var speed = 0
var velocity = Vector2.ZERO
var tempvelocity = speed
var direction = Vector2.ZERO
var damage

func summon(sped, dir, dam, initialvel, anim = 'arraw', type = 'player', timout = 0, corruption = 0):
	#yield(get_tree().create_timer(timout), "timeout")
	direction = dir
	damage = dam
	tempvelocity = speed
	$Tween.interpolate_property(self, 'speed', 0.0, sped, 0.7, Tween.TRANS_EXPO)
	$Tween.start()
	print(corruption)
	if !corruption == 8:
		$AnimatedSprite.play("nor")
		$Particles2D.emitting = true
		$Particles2D2.emitting = false
	else:
		$AnimatedSprite.play("cor")
		$Particles2D.emitting = false
		$Particles2D2.emitting = true
	if type == 'enemy':
		set_collision_layer_bit(1, false)
		set_collision_layer_bit(2, true)
		add_to_group("enemy")
	
func _physics_process(delta):
	position += transform.x * speed * delta / 3

func impact():
	queue_free()

func _on_Area2D_body_entered(body):
	if ((!body.is_in_group('owl')) && (body!=self && !body.is_in_group('proj'))):
		impact()
		


func _on_VisibilityNotifier2D_screen_exited():
	pass
#	queue_free()
