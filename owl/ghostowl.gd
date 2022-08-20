extends KinematicBody2D


var direction = Vector2.ZERO
var endposition = Vector2()
var start
var end
var speed = 3000
# Called when the node enters the scene tree for the first time.
func ready(dir, pos, endpos, corruption, start = 0, end = 0):
	direction = dir
	endposition = endpos
	speed = speed + speed*(pow(corruption, 2)/64)*0.25
	global_position = pos
	var distance = sqrt(pow(endpos.x - pos.x, 2)+pow(endpos.y - pos.y, 2))
	if direction.x != 0:
		$AnimatedSprite.play('fly')
		if direction.x == -1:
			$AnimatedSprite.flip_h = true
		else:
			$AnimatedSprite.flip_h = false
	elif direction.y == -1:
		$AnimatedSprite.play('fly_up')
	else:
		$AnimatedSprite.play('fly_down')
	$AnimationPlayer.play("going_in")
	$Tween.interpolate_property(self, 'global_position', pos, endpos, distance/speed)
	$Tween.start()

func end():
	if direction.x != 0:
		$AnimatedSprite.play('end')
		if direction.x == -1:
			$AnimatedSprite.flip_h = true
		else:
			$AnimatedSprite.flip_h = false
	elif direction.y == -1:
		$AnimatedSprite.play('end_up')
	else:
		$AnimatedSprite.play('end_down')
	$AnimationPlayer.play('out')

		


func _on_Tween_tween_all_completed():
	end()
	$Tween.interpolate_property(self, 'global_position', global_position, endposition + 500*direction, 500/speed)
	$Tween.start()
	


