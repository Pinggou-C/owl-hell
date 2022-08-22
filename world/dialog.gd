extends Node2D
var curline = 1
var corrupt

const text = [[true,'Hello there little cat.',  'As it would seem, thee have been going around and causing a lot of trouble.',
'The timeline has not been a fan of thine activities.',
'Thine actions have caused the time stream to be in knots, with catastrophic results.',
'Thus now you leave me no choice.',  'As protector of the time-space continue-hoot, I must keep thou trapped in this time loop.',
 'It is the only way to keep thee from causing even more damage.',
'Nowforth! It is just thou and I in this battle which will last for eternity!'],
[false,'Thine determination is admirable, but I am afraid that you shall not leave this place.'],
[false,'No matter how hard thou try, I will give it my everything to keep the timeline in order and keep thou trapped here, for it is my duty.'],
[false,'No matter how hard thou try, I will give it my everything to keep the timeline in order and keep thou trapped here, for it is my duty.'],
[false,'Thy im-peck-able determination will be thine undoing!'],
[false,'Thy im-peck-able determination will be thine undoing!'],
[false,'Did you really think that would work?'],
[false,'skriiiiaaaassk!!'],
[false,'skriiiiaaaassk!!'],
[false,'skriiiiaaaassk!!']]

func dialog(corrupting):
	curline = 0
	print(corrupting)
	corrupt = corrupting
	$Tween.interpolate_property($Control2/name, 'rect_scale', Vector2(0, 0), Vector2(1, 1), 0.5, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	$Tween.start()
	$Tween2.interpolate_property($Control2/text, 'rect_scale', Vector2(0, 0), Vector2(1, 1), 0.5, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	$Tween2.start()
	$Control2/text.text = text[corrupting][1]
	var curline = 1
	#et_tree().paused = true
	print(text[corrupt])
	if text[corrupting][0] == false:
		$Timer.start(3)
	else:
		$Timer2.start(2)
		

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		if !$Timer.is_stopped():
			$Timer.stop()
			_on_Timer_timeout()
		if !$Timer2.is_stopped():
			$Timer2.stop()
			_on_Timer2_timeout()
			



func _on_Timer_timeout():
	#get_tree().paused = false
	get_parent().dialog_end()
	$Tween.interpolate_property($Control2/name, 'rect_scale', Vector2(1, 1), Vector2(0, 0), 1, Tween.TRANS_EXPO, Tween.EASE_IN)
	$Tween.start()
	$Tween2.interpolate_property($Control2/text, 'rect_scale', Vector2(1, 1), Vector2(0, 0), 1, Tween.TRANS_EXPO, Tween.EASE_IN)
	$Tween2.start()


func _on_Timer2_timeout():
	print(curline)
	curline += 1
	$Control2/text.text = text[corrupt][curline]
	if curline == text[corrupt].size()-1:
		$Timer.start(10)
	else:
		$Timer2.start(5)
	
	
