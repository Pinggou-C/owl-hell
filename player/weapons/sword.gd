extends Node2D

var named = "shortsword"
var delay = 0.2
var player
var damage = 8


func attack(mousepos):
	$AnimationPlayer.play('attack')
