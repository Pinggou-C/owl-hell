extends Node2D

var currentplayer = 1




func audio(song, time, transition, transition2):
	if currentplayer == 1:
		$song2.stream = song
		currentplayer = 2
		$song1/Tween.interpolate_property($song1, 'volume_db', 0.0, -25.0, time, transition)
		$song1/Tween.start()
		$song2/Tween.interpolate_property($song2, 'volume_db', -25.0, 0.0, time, transition2)
		$song2/Tween.start()
	if currentplayer == 2:
		$song2.song2 = song
		currentplayer = 1
		$song2/Tween.interpolate_property($song1, 'volume_db', 0.0, -25.0, time, transition)
		$song2/Tween.start()
		$song1/Tween.interpolate_property($song2, 'volume_db', -25.0, 0.0, time, transition2)
		$song1/Tween.start()
