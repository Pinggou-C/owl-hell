extends KinematicBody2D
var speed = 0
var velocity = Vector2.ZERO
var tempvelocity = Vector2.ZERO
var direction = Vector2.ZERO
var damage

func summon(sped, dir, dam, initialvel, anim = 'arraw', type = 'player'):
	speed = sped
	direction = dir
	damage = dam
	tempvelocity = speed * direction + initialvel
	print(tempvelocity, speed, direction, initialvel)
	if type == 'enemy':
		set_collision_layer_bit(1, false)
		set_collision_layer_bit(2, true)
		add_to_group("enemy")
	
func _physics_process(delta):
	velocity = tempvelocity * delta
	velocity = move_and_slide(velocity)

func impact():
	#controller.shake(.2)
	controller._freeze_frame(0.05, .075)
	queue_free()

func _on_Area2D_body_entered(body):
	if ((body.is_in_group('player') && is_in_group('enemy'))|| !body.is_in_group('player')) && (body!=self && !body.is_in_group('proj')):
		print(body)
		impact()
		


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
