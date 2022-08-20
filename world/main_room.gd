extends Light2D

var on = false
func _ready():
	energy = 0.1

func light(body):
	if body.is_in_group('trueplayer') && on == false:
		on = true
		$Tween.interpolate_property(self, 'energy', 0.1, 0.75, 0.5, Tween.TRANS_CIRC, Tween.EASE_OUT)
		$Tween.start()
