extends Node
var shouldbeplaying = null
var playing = false
var vol
var wasplaying
var paused
var isplaying
func musiconof():
	if Settings.music == false:
		for child in get_children():
			if child.playing == true && child.stream_paused == false:
				child.stream_paused = true
				paused = child
	else:
		for child in get_children():
			if child.stream_paused == true && child == paused:
				child.stream_paused = false
func changevol():
	for child in get_children():
		if child.playing == true:
			vol = (Settings.musiclevel - 100) / 3
			child.volume_db = vol
func goplay(which):
	for child in get_children():
		if child.playing == true && child != get_node(which):
			$Tween.interpolate_property(child, "volume_db", vol, -60, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.start()
			wasplaying = child
	if Settings.music == true && get_node(which).playing != true:
		shouldbeplaying = which
		$Tween.interpolate_property(get_node(which), "volume_db", -60, (Settings.musiclevel - 100) / 3, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
		get_node(which).play(0.0)
		isplaying = get_node(which)
		$Tween.start()

func _on_Tween_tween_completed(object, _key):
	if object == wasplaying:
		object.stop()
