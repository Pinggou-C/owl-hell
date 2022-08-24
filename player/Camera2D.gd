extends Camera2D

export var decay = 0.7  # How quickly the shaking stops [0, 1].
export var max_off = Vector2(120, 75)  # Maximum hor/ver shake in pixels.
export var max_roll = 0.1  # Maximum rotation in radians (use sparingly).
export (NodePath) var target  # Assign the node this camera will follow.

var trauma = 0.0  # Current shake strength.
var trauma_power = 2 # Trauma exponent. Use [2, 3].
func _ready():
	controller.camera = self
	randomize()

func add_trauma(amount, decayy = 0.7, set = false):
	decay = decayy
	if set == true:
		trauma = amount
	else:
		trauma = min(trauma + amount, 1.0)


func _process(delta):
	if target:
		global_position = get_node(target).global_position
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()

func shake():
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * rand_range(-1, 1)
	offset.x = max_off.x * amount * rand_range(-1, 1)
	offset.y = max_off.y * amount * rand_range(-1, 1)
