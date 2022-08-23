extends Timer
var camera = null


func _freeze_frame(timescale, duration):
	#OS.delay_msec(duration*1000)
	#Engine.time_scale = timescale
	#yield(get_tree().create_timer(duration*timescale), 'timeout')
	#Engine.time_scale = 1.0
	
	set_wait_time(duration) # time in seconds
	start()
	get_tree().paused = true

func shake(amount, decay):
	if camera != null:
		camera.add_trauma(amount, decay)








func _on_freeze_timeout():
	get_tree().paused = false
