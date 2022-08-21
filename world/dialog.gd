extends Node2D
var curline = 1
var corrupt

const text = [[true,'Did you really think that would work?', 'you are a foolish creature'],
[true,'Did you really think that would work?', 'you are a foolish creature'],
[false,'Did you really think that would work?'],
[false,'Did you really think that would work?'],
[false,'Did you really think that would work?'],
[false,'Did you really think that would work?'],
[false,'Did you really think that would work?'],
[false,'Your impeck-able determination will be your undoing!!'],
[false,'Your impeck-able determination will be your undoing!!'],
[false,'Your impeck-able determination will be your undoing!!']]

func dialog(corrupting):
	curline = 0
	print(corrupting)
	corrupt = corrupting
	$Control2.visible = true
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
	$Control2.visible = false


func _on_Timer2_timeout():
	print(curline)
	curline += 1
	$Control2/text.text = text[corrupt][curline]
	if curline == text[corrupt].size()-1:
		$Timer.start(3)
	else:
		$Timer2.start(2)
	
	
