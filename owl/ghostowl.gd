extends KinematicBody2D


var direction = Vector2.ZERO
var endposition = Vector2()
var start
var end
var speed = 3000
# Called when the node enters the scene tree for the first time.
func ready(dir, pos, endpos, corruption, start = 0, end = 0):
	if dir.x ==1:
		$Particles2D.process_material.angle = -90
		$Particles2D2.process_material.angle = -90
	if dir.x ==-1:
		$Particles2D.process_material.angle = 90
		$Particles2D2.process_material.angle = 90
		
	if dir.y ==1:
		$Particles2D.process_material.angle = -180
		$Particles2D2.process_material.angle = -180
	if dir.y ==-1:
		$Particles2D.process_material.angle = 0
		$Particles2D2.process_material.angle = 0
	if corruption < 8:
		$anim.play('fly')
		$Particles2D.emitting = true
		$Particles2D2.emitting= false
	else:
		$anim.play('corfly')
		$Particles2D.emitting = false
		$Particles2D2.emitting = true
	direction = dir
	endposition = endpos
	speed = speed + speed*(pow(corruption, 2)/64)*0.25
	global_position = pos
	var distance = sqrt(pow(endpos.x - pos.x, 2)+pow(endpos.y - pos.y, 2))

	$AnimationPlayer.play("going_in")
	$Tween.interpolate_property(self, 'global_position', pos, endpos, distance/speed)
	$Tween.start()

func end():

	$AnimationPlayer.play('out')

		


func _on_Tween_tween_all_completed():
	end()
	$start.interpolate_property(self, 'global_position', global_position, endposition + 500*direction, 500/speed)
	$start.start()


func hit():
	pass


