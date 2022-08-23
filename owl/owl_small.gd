extends KinematicBody2D

var rng = RandomNumberGenerator.new()
var direction = Vector2.ZERO
var speed = 0
var ending = 0
var endingtime = 0
var starting = 0
var startingtime = 0
var livetime  = 0
var velocity = Vector2.ZERO
var originalpos = Vector2(-100, -100)
var rotate_speed = 0

func _ready():
	rng.randomize()
	visible = false
	set_physics_process(false)
	rotation_degrees = rng.randi_range(0, 36)*10
	rotate_speed =  rng.randi_range(18, 48) *(rng.randi_range(0, 1)*2-1)*10
func _physics_process(delta):
	#print(position)
	velocity = speed*direction*delta
	velocity = move_and_slide(velocity)
	rotation_degrees+= rotate_speed*delta



func summon(pos, dir, sped, livetim = 8.0, start = 0.0, starttime = 0.0, end = 0.0, endtime = 2.0, startt = false):
	rng.randomize()
	rotation_degrees = rng.randi_range(0, 36)*10
	rotate_speed =  rng.randi_range(18, 48) *(rng.randi_range(0, 1)*2-1)*10
	$AnimatedSprite.play('book' + String(rng.randi_range(1, 6)))
	visible = true
	originalpos = pos
	position = pos
	direction = dir
	speed = sped
	ending = end
	endingtime = endtime
	starting = start
	startingtime = starttime
	livetime = livetim
	if startt == true:
		set_physics_process(true)
		if start !=0.0:
			if dir.y == 0:
				$Tweenin.interpolate_property(self, 'position:y', position.y, position.y+start, starttime, Tween.EASE_OUT)
				$Tweenin.start()
			if dir.x == 0:
				$Tweenin.interpolate_property(self, 'position:x', position.x, position.x+start, starttime, Tween.EASE_OUT)
				$Tweenin.start()
		$livetimer.wait_time = livetime
		$livetimer.start()
func starttt(cor):
	$CollisionShape2D.call_deferred('set', 'disabled', false)
	#print(position)
	speed = 50000 + 20000 * cor /8
	visible = true
	if starting !=0.0:
		if direction.y == 0:
			$Tweenin.interpolate_property(self, 'position:y', position.y, position.y+starting, startingtime, Tween.EASE_OUT)
			$Tweenin.start()
		if direction.x == 0:
			$Tweenin.interpolate_property(self, 'position:x', position.x, position.x+starting, startingtime, Tween.EASE_OUT)
			$Tweenin.start()
	$livetimer.wait_time = livetime
	$livetimer.start()
	set_physics_process(true)


func _livetimer_timeout():
	if direction.y == 0:
		$tweenout.interpolate_property(self, 'position:y', position.y, position.y+ending, endingtime, Tween.EASE_IN)
		$tweenout.start()
	if direction.x == 0:
		$tweenout.interpolate_property(self, 'position:x', position.x, position.x+ending, endingtime, Tween.EASE_IN)
		$tweenout.start()
	$CollisionShape2D.disabled = true


func tweenout_completed():
	$tweenout2.interpolate_property(self, 'self_modulate', self_modulate, Color(0, 0, 0, 0), endingtime/3, Tween.EASE_IN)
	$tweenout2.start()


func _on_tweenout2_tween_all_completed():
	set_physics_process(false)
	visible = false
	position = originalpos
	$CollisionShape2D.disabled = true
	velocity = Vector2.ZERO


func _on_Tweenin_tween_all_completed():
	#print('ready')
	$CollisionShape2D.disabled = false

func hit():
	pass
