extends Light2D

var on = false
func _ready():
	energy = 0.1

func light(body):
	if body.is_in_group('trueplayer') && on == false:
		on = true
		$Tween.interpolate_property(self, 'energy', 0.1, 0.75, 0.5, Tween.TRANS_CIRC, Tween.EASE_OUT)
		$Tween.start()
		$StaticBody2D/CollisionShape2D2.set_deferred('disabled', false)
		$StaticBody2D/LightOccluder2D.visible = true
		$Tween2.interpolate_property($main_room2, 'energy', 0.8, 0.1, 0.5, Tween.TRANS_CIRC, Tween.EASE_OUT)
		$Tween2.start()
