extends Node2D

func _ready():
	if get_parent().corruption == 8:
		$nest1.visible = false
		$nest2.visible = true
	else:
		$nest2.visible = false
		$nest1.visible = true
