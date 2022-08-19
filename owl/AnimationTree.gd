extends AnimationTree


func set_condition(condition, value):
	set("parameters/conditions/"+condition, value)
