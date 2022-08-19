extends Node2D

var direction
var startpos
var endpos
var corruption
func ready(step, dir, sp, ep, cr):
	direction = dir
	startpos = sp
	endpos = ep
	corruption = cr
	$AnimationPlayer.playback_speed = step
	$AnimationPlayer.play("start")


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()

func owl():
	$KinematicBody2D.ready(direction, startpos, endpos, corruption)
