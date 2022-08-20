extends KinematicBody2D

#curruption 0-8
var corruption = 8
const max_hp = 50
var hp = 50
const THRESHOLD = 3
var threshold = 0



var screech = false
var grounded = true
var moving = false
var waiting = false
var landing = false
var attacking = false
var player
#movement
var direction
var movetarget
var landtarget = Vector2.ZERO
const speed = 20000
var velocity = Vector2.ZERO

onready var owl = preload("res://owl/owl_small.tscn")
onready var ind = preload("res://indicator.tscn")
onready var feather = preload("res://owl/feather.tscn")
onready var ghost = preload("res://owl/ghostowl.tscn")
#attacks
var patterns = {'start':['fly','screech', 'feather'],
 'corruptstart':['fly','longscreech', 'feather', 'timer'],
 'high_hp':['screech', 'cross', 'feather', 'swoop', 'wait'],
 'high_hp2':['screech', 'fly', 'missile', 'wait'],
 'mid_hp':['screech', 'missile', 'fly', 'conferge', 'wait'],
 'mid_hp2':['screech', 'swoop', 'screech', 'cross', 'wait'],
 'low_hp':['screech', 'swoop', 'missile', 'wait'],
 'low_hp2':['screech','feather', 'conferge','fly', 'missile', 'wait']}

#states attacktimemin and max and delay and damage, and can gounded
var attacks = {'timer':[1.0, 2.0, 0.0, 0.0, null],'fly':[3.0, 5.0, 1.0, 0.0, null], 'swoop':[3.0, 5.0, 2.0, 2.0, null], 'screech':[1.0, 1.0, 0.2, 0.0, true], 'feather':[1.0, 1.0, 0.5, 1.0, null], 'cross':[1.0, 1.0, 2.0, 1.0, null], 'longscreech':[2.0, 2.0, 0.33, 0.0, true], 'missile':[3.0, 5.0, 1.5, 2.0, true], 'bomb':[4.0, 7.0, 1, 2.0, true], 'conferge':[1.0, 1.5, 0.5, 0.0, null], 'encircle':[1.0, 1.0, 0.33, 0.0, null]}
var current_pattern = null# setget pattern#, attackchange
var curpat = null
var current_attack
var pattern_nr = 0
var last_attack
var I_frames = 0.2
var I_FrameD = false

var far = true
var mid = false
var close = false
var min_distance = "far"


var rng = RandomNumberGenerator.new()


var crossx1 = []
var crossy1 = []
var crossx2 = []
var crossy2 = []


func _ready():
	for i in range(4000/200):
		var ow = owl.instance()
		get_parent().call_deferred('add_child',ow)
		ow.summon(Vector2(i*200, 0-rng.randf_range(0, 200)),Vector2(0, 1), 40000, 12.0, 0.0, 0.0, 0.0, 0.0, false)
		var ows = owl.instance()
		get_parent().call_deferred('add_child',ows)
		ows.summon(Vector2(i*200+125, 2000+rng.randf_range(0, 200)),Vector2(0, -1), 40000, 12.0, 0.0, 0.0, 0.0, 0.0, false)
		crossy1.append(ow)
		crossy2.append(ows)
		var own = owl.instance()
		get_parent().call_deferred('add_child',own)
		own.summon(Vector2(0-rng.randf_range(0, 200), i*200),Vector2(1, 0), 40000, 12.0, 120.0, 1.0, -120.0, 1.0, false)
		var owns = owl.instance()
		get_parent().call_deferred('add_child',owns)
		owns.summon(Vector2(3000+rng.randf_range(0, 200), i*200+125),Vector2(-1, 0), 40000, 12.0, 120.0, 1.0, -120.0, 1.0, false)
		crossx1.append(own)
		crossx2.append(owns)
	#hp = max_hp
	if corruption == 8:
		current_pattern = patterns['corruptstart']
		pattern(patterns['corruptstart'])
		curpat = 'corruptstart'
	else:
		#current_pattern = patterns['start']
		#print('g')
		pattern(patterns['start'])
		#print(current_pattern)
		curpat = 'start'
	player = get_parent().get_child(0)

func _physics_process(delta):
	if grounded != true && moving == true:
		velocity = speed*global_position.direction_to(movetarget)*delta
		velocity = move_and_slide(velocity)
	#print(screech)


#player interactions
func hurt(damage):
	if I_FrameD == false:
		print(hp)
		I_FrameD = true
		#print(waiting)
		$Timer.wait_time = I_frames
		$Timer.start()
		hp -= damage
		threshold += damage
		#print(hp)
		if waiting == true:
			print('wait')
			threshold += 1
			if !$waittimer.is_stopped():
				$short.wait_time = 1.5 - 1*(pow(corruption, 2)/64)
				$short.start()
			if threshold == THRESHOLD:
				threshold = 0
				move(current_pattern)
			
		if hp <=0:
			die()

func die():
	if corruption < 8:
		normaldie()
	else:
		truedeath()
		

func normaldie():
	pass

func truedeath():
	pass

func IFRAMES():
	I_FrameD = false



#actions
func attack(attack):

	if attack != 'wait':
		if attacks[attack][4] == true && grounded == false:
			flying(false, attack)
		elif attacks[attack][4] == false && grounded == true:
			flying(true, attack)
		else:
			$attacktime.wait_time = attacks[attack][2]+attacks[attack][0] - attacks[attack][0]*(corruption/12)
			$attacktime.start()
			call(attack)
			attacking = true
			if attacks[attack][4] == null && grounded == true:
				flying(true)
	else:
		if grounded == false:
			flying(false)
		$waittimer.wait_time = 12 - 4*(pow(corruption, 2)/64)
		$waittimer.start()
		waiting = true

func attack_end():
	attacking = false
	if last_attack == 'screech'||last_attack == 'longscreech':
		screech = false
		player.stop_push()
	move(current_pattern)
	if last_attack == 'fly' || 'swoop':
		$AnimationPlayer.play('land')
	
	

func attackdelayend():
	pass # Replace with function body.

func move(pattern):
	if attacking ==false:
		if !pattern.size() <= pattern_nr:
			var attack = pattern[pattern_nr]
			pattern_nr += 1
			attack(attack)
			last_attack = attack
		else:
			newpattern()

func newpattern():
	if hp >0:
		pattern_nr = 0
		var newpattern = null
		if (max_hp / hp) >= 4:
			newpattern = patterns['low_hp']
		elif (max_hp / hp) >= 1.5:
			newpattern = patterns['mid_hp']
		elif (max_hp / hp) >= 1:
			newpattern = patterns['high_hp']
		current_pattern = newpattern
		move(current_pattern)

func pattern(new_value):
	current_pattern = new_value
	move(current_pattern)


#func attackchange():
#	return current_pattern
func timer():
	pass
#attacks
func fly():
	moving = false
	rng.randomize()
	var x = rng.randi_range(0, 1920)
	var y = rng.randi_range(0, 1080)
	$AnimationPlayer.play('fly_up')
	landtarget = Vector2(x, y)
	
func landing():
	moving = true
	global_position = landtarget
	flying(false)
	$hurtbox/CollisionShape2D.disabled = false

func swoop():
	rng.randomize()
	$Tween.interpolate_property($anim, 'modulate', modulate, Color(1, 1, 1, 0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	$hurtbox/CollisionShape2D.disabled = true
	var number = ceil(rng.randi_range(10, 14) + round(8 * pow(corruption, 2)/64*2))
	var lastx = []
	var lasty = []
	var aimed = ceil(number / 2  + 8 * pow(corruption, 2) / 64 * 2) + 1
	var unaimed = floor(number / 2  + 8 * pow(corruption, 2) / 64 * 2) - 1
	var lats = []
	var lastxis = ['x', 'x']
	for i in number:
		var dott
		yield(get_tree().create_timer(0.3 - 0.15*(corruption/8)), "timeout")
		var axis
		if (rng.randi_range(0, 1) == 1 || (lastxis[0] == 'x' && lastxis[1]== 'x')) && !(lastxis[0] == 'y' && lastxis[1]== 'y'):
			axis = 'y'
		else:
			axis = 'x'
		lastxis.push_back(axis)
		if lastxis.size() > 2:
			lastxis.remove(0)
		var startpos = Vector2.ZERO
		var endpos = Vector2.ZERO
		var dir = rng.randi_range(0, 1)*2 -1
		var lenth = rng.randi_range(4, 10)*300
		var gh = true
		var lastnr = -1
		lenth = 3000
		for h in lats:
			if h != lastnr:
				gh = false
			lastnr = h
		if ((((rng.randi_range(0,1) == 1 && aimed > 0 )|| unaimed == 0 )&& (gh == false))|| (gh == true && lastnr == 0)):
			lats.append(1)
			
			aimed -=1
			if axis == 'y':
				dott = Vector2(1, 0)
				startpos.x = stepify(player.global_position.x, 200) + rng.randi_range(1, (ceil(lenth/200-9)))*-dir*200
				startpos.y = stepify(player.global_position.y, 200) + rng.randi_range(-2, 2)*200 
				
				while lasty.has(startpos.y):
					startpos.y += (rng.randi_range(0, 1)*2 -1)*200
				if rng.randi_range(0, 3) != 0:
					startpos += player.direction * 200 * rng.randi_range(0, 3)
				endpos = startpos + Vector2(lenth, 0)*dir
				if dir ==-1:
					startpos.x = 3000 
					endpos.x = 0
				else:
					startpos.x = 0
					endpos.x = 3000
			else:
				dott = Vector2(0, 1)
				
				startpos.y = stepify(player.global_position.y, 200) + rng.randi_range(1, (ceil(lenth/200-9)))*-dir*200
				startpos.x = stepify(player.global_position.x, 200) + rng.randi_range(-2, 2)*200
				startpos.y = 3000
				if rng.randi_range(0, 3) != 0:
					startpos += player.direction * 200* rng.randi_range(0, 3)
				while lastx.has(startpos.x):
					startpos.x += (rng.randi_range(0, 1)*2 -1)*200
				endpos = startpos + Vector2(0, lenth)*dir
				if dir ==-1:
					startpos.y = 3000 
					endpos.y = 0
				else:
					startpos.y = 0
					endpos.y = 3000
		else:
			lats.append(0)
			unaimed -=1
			if axis == 'y':
				dott = Vector2(1, 0)
				3000
				startpos.x = stepify(player.global_position.x, 200) + rng.randi_range(2, (ceil(lenth/200-7)))*-dir*200
				startpos.y = stepify(player.global_position.y, 200) + rng.randi_range(2, (ceil(lenth/200-7)))*-dir*200
				
				while lasty.has(startpos.y):
					startpos.y += (rng.randi_range(0, 1)*2 -1)*200
				endpos = startpos + Vector2(lenth, 0)*dir
				if dir ==-1:
					startpos.x = 3000 
					endpos.x = 0
				else:
					startpos.x = 0
					endpos.x = 3000
			else:
				dott = Vector2(0, 1)
				
				startpos.y = stepify(player.global_position.y, 200) + rng.randi_range(2, (ceil(lenth/200-7)))*-dir*200
				startpos.x = stepify(player.global_position.x, 200) + rng.randi_range(2, (ceil(lenth/200-7)))*-dir*200
				
				while lastx.has(startpos.x):
					startpos.x += (rng.randi_range(0, 1)*2 -1)*200
				endpos = startpos + Vector2(0, lenth)*dir
				if dir ==-1:
					startpos.y = 3000 
					endpos.y = 0
				else:
					startpos.y = 0
					endpos.y = 300
		if lats.size() > 3:
			lats.erase(0)
		if startpos.x < 0:
			endpos.x -= startpos.x
			startpos.x -= startpos.x
		elif startpos.x > 3000:
			endpos.x -= startpos.x-3000
			startpos.x -= startpos.x-3000
		if endpos.x <0: 
			startpos.x -= endpos.x
			endpos.x -= endpos.x
		elif endpos.x> 3000:
			startpos.x -= endpos.x-3000
			endpos.x -= endpos.x-3000
		if startpos.y < 0:
			endpos.y -= startpos.y
			startpos.y -= startpos.y
		elif startpos.y > 3000:
			endpos.y -= startpos.y-3000
			startpos.y -= startpos.y-3000
		if endpos.y <0: 
			startpos.y -= endpos.y
			endpos.y -= endpos.y
		elif endpos.y> 3000:
			startpos.y -= endpos.y-3000
			endpos.y -= endpos.y-3000
		endpos.x = stepify(endpos.x, 200)
		endpos.y = stepify(endpos.y, 200)
		startpos.x = stepify(startpos.x, 200)
		startpos.y = stepify(startpos.y, 200)
		if startpos.y > endpos.y || startpos.x > endpos.x:
			dott *= -1
		lasty.append(startpos.y)
		lastx.append(startpos.x)
		if lastx.size() > 6:
			lastx.erase(0)
		if lasty.size() > 6:
			lasty.erase(0)
		var ined = ind.instance()
		ined.get_child(0).rect_size = Vector2(lenth, 300)
		ined.get_child(0).rect_position = Vector2(0, -150)
		get_parent().add_child(ined)

		ined.ready(3.0 + (corruption-8)/4, dott, startpos, endpos, corruption)
		ined.global_position = startpos
		ined.look_at(endpos)
		$ColorRect2.rect_position = startpos - global_position
		$ColorRect3.rect_position = endpos - global_position
	rng.randomize()
	var x = rng.randi_range(0, 1920)
	var y = rng.randi_range(0, 1080)
	landtarget = Vector2(x, y)
	yield(get_tree().create_timer(4), "timeout")
	$Tween.interpolate_property($anim, 'modulate', Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	$hurtbox/CollisionShape2D.disabled = false
	landing()
	
func screech():
	print('ha')
	$AnimationPlayer.play("screetch")
	screech = true
	print(screech)
	player.push(self, 50000)
	
		

func longscreech():
	print('flyl')

func cross():
	rng.randomize()
	if rng.randi_range(0, 1) == 0:
		for i in crossy1:
			i.starttt()
		for i in crossy2:
			i.starttt()
		yield(get_tree().create_timer(2), "timeout")
		for i in crossx1:
			i.starttt()
		for i in crossx2:
			i.starttt()
	else:
		for i in crossx1:
			i.starttt()
		for i in crossx2:
			i.starttt()
		yield(get_tree().create_timer(2), "timeout")
		for i in crossy1:
			i.starttt()
		for i in crossy2:
			i.starttt()
func feather():
	var nru = 1
	if hp / max_hp * 100 >= 75:
		nru = 1
	elif hp / max_hp * 100 >= 50:
		nru = 2
	elif hp / max_hp * 100>= 25:
		nru = 3
	elif hp / max_hp * 100>= 0:
		nru = 4
	print(nru)
	for g in range(nru):
		yield(get_tree().create_timer(0.4 - ((corruption-8.0)/32.0) + 0.2/nru), "timeout")
		print(0.25 - ((corruption-8.0)/32.0) + 0.25/nru)
		print((corruption-8.0)/32.0)
		for i in range(7):
			var feth = feather.instance()
			get_parent().add_child(feth)
			feth.position = $wingtip.global_position
			feth.summon(1200, Vector2(0, 1), 10, Vector2(0, 0), "feather", 'enemy')
			feth.look_at(get_parent().get_child(0).get_global_position()) 
			feth.rotate((i-3)*0.133)

func conferge():
	print('flyc')

func encircle():
	print('flye')
func missile():
	print('flym')

func bomb():
	print('flyb')


#moving
func flying(airborn, attack = null, moving = null, pat= 'static'):
	print('fly')
	if attacking != true:
		print('fly')
		if grounded == false && airborn == false:
			landing = true
			#$anim.play('land')
			$Tween2.interpolate_property(self, 'position:y', position.y, position.y - 150, .4, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			$Tween2.start()
			grounded = true
			moving = false
		elif grounded == true && airborn == true:
			landing = false
			#$anim.play('fly')
			$Tween2.interpolate_property(self, 'position:y', position.y, position.y + 150, .33, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			$Tween2.start()
			grounded = false
		if attack !=null:
			yield(get_tree().create_timer(0.2), "timeout")
			attack(attack)
			landing = false
		if moving != null:
			yield(get_tree().create_timer(0.2), "timeout")
			moving_around(moving, pat)
			landing = false

func moving_around(target = get_global_position(), pattern = 'static'):
	if grounded == true:
		flying(true, null, target, pattern)
	else:
		moving = true
		

#sight of bigbird
func rangechange(newmax):
	min_distance = newmax


#sight
func vision():
	pass

func farin(body):
	if body.is_in_group('playerbody'):
		far = true
		rangechange("far")


func farout(body):
	if body.is_in_group('playerbody'):
		far = false
		rangechange("out")


func midin(body):
	if body.is_in_group('playerbody'):
		mid = true
		rangechange("mid")


func midout(body):
	if body.is_in_group('playerbody'):
		mid = false
		rangechange("far")


func closein(body):
	if body.is_in_group('playerbody'):
		close = true
		rangechange("close")


func closeout(body):
	if body.is_in_group('playerbody'):
		close = false
		rangechange("mid")




func _on_hurtbox_body_entered(body):
	if  body.is_in_group('player_weapons'):
		hurt(1)


func _on_waittimer_timeout():
	$short.stop()
	$waittimer.stop()
	move(current_pattern)
	waiting = false
	threshold = 0
