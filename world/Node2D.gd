extends Node2D

var max_hp = 9
var hp = 9

func _ready():
	for i in get_children():
		i.visible = true
 
func hp(new_hp):
	if hp < new_hp:
		for i in range(0, abs(hp-max_hp)):
			#print(i, 'up')
			get_node('hp'+String(i+1)).visible = false
	hp = new_hp
	for i in range(0, max_hp - hp):
		print(max_hp-i, 'down')
		get_node('hp'+String(max_hp-i)).visible = false
