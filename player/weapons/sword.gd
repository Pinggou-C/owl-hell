extends Node2D

var named = "shortsword"
var delay = 0.4
var player
var damage = 8
onready var owl = preload("res://owl/owl_small.tscn")
func attack(mousepos):
	var ow = owl.instance()
	
	add_child(ow)
	ow.summon(Vector2.ZERO, Vector2(1, 0), 10000, 12.0, 120.0, 1.0, -180.0, 1.0)
