extends KinematicBody2D

#curruption 0-8
var corruption = 0
const max_hp = 1
var hp = 1
const THRESHOLD = 3
var threshold = 0



var screech = false
var grounded = true
var moving = false
#[sidetoside, statid]
var movepattern = null
var mov 
var movsid = 0

var waiting = false
var landing = false
var attacking = false
var player
#movement
var direction
var movetarget
var landtarget = Vector2.ZERO
const speed = 600
const accel = 1500
var velocity = Vector2.ZERO

onready var owl = preload("res://owl/owl_small.tscn")
onready var ind = preload("res://indicator.tscn")
onready var feather = preload("res://owl/feather.tscn")
onready var ghost = preload("res://owl/ghostowl.tscn")
onready var hissile = preload("res://owl/hissil2e.tscn")
#attacks
var patterns = {'start':['missile', 'feather'],
 'corruptstart':['feather','missile', 'feather', 'timer'],
 'high_hp':['screech', 'cross', 'feather', 'swoop', 'wait'],
 'high_hp2':['screech', 'fly', 'missile', 'swoop','wait'],
 'mid_hp':['screech', 'missile', 'fly', 'conferge', 'swoop','wait'],
 'mid_hp2':['screech', 'swoop', 'screech', 'cross', 'swoop','wait'],
 'low_hp':['screech', 'swoop', 'feather', 'swoop','wait'],
 'low_hp2':['screech','feather', 'conferge','fly', 'missile', 'swoop','wait']}

#states attacktimemin and max and delay and damage, and can gounded
var attacks = {'timer':[1.0, 2.0, 0.0, 0.0, null],'fly':[3.0, 5.0, 1.0, 0.0, null], 'swoop':[3.0, 5.0, 2.0, 2.0, null], 'screech':[2.0, 2.0, 0.5, 0.0, true], 'feather':[7.0, 7.0, 3.0, 1.0, null], 'cross':[1.0, 1.0, 2.0, 1.0, null], 'longscreech':[2.0, 2.0, 0.33, 0.0, true], 'missile':[8.0, 8.0, 2.5, 2.0, true], 'bomb':[4.0, 7.0, 1, 2.0, true], 'conferge':[1.0, 1.5, 0.5, 0.0, null], 'encircle':[1.0, 1.0, 0.33, 0.0, null]}
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
	ready()
	
	print(corruption)
	for i in range(4000/200):
		var ow = owl.instance()
		get_parent().call_deferred('add_child',ow)
		ow.summon(Vector2(i*200, 0-rng.randf_range(0, 200)),Vector2(0, 1), 40000, 12.0, 0.0, 0.0, 0.0, 0.0, false)
		var ows = owl.instance()
		get_parent().call_deferred('add_child',ows)
		ows.summon(Vector2(i*200+125, 3000+rng.randf_range(0, 200)),Vector2(0, -1), 40000, 12.0, 0.0, 0.0, 0.0, 0.0, false)
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
func ready():
	$attackdelay.stop()
	$Timer.stop()
	$attacktime.stop()
	$waittimer.stop()
	$short.stop()
	$AnimationPlayer.stop()
#	$Tween.stop()
	#$Tween2.stop()
	$hurtbox/CollisionShape2D.set_deferred('disabled', false)
	scale = Vector2(1, 1)
	modulate = Color(1, 1, 1, 1)
	$anim.position = Vector2(0, 0)
	hp = max_hp
	global_position = Vector2(1500, 1500)
	player = get_parent().get_child(0)
	corruption = get_parent().corruption
	if corruption < 8:
		$anim.play('idle')
	else:
		$anim.play('coridle')
	var threshold = 0


	current_pattern = null# setget pattern#, attackchange
	curpat = null
	current_attack= null
	pattern_nr = 0
	last_attack= null

	I_FrameD = false

	far = true
	mid = false
	close = false
	min_distance = "far"


	crossx1 = []
	crossy1 = []
	crossx2 = []
	crossy2 = []
	screech = false
	grounded = true
	moving = false
	movepattern = null
	mov = null
	movsid = 0
	waiting = false
	landing = false
	attacking = false
	direction= null
	movetarget= null
	landtarget = Vector2.ZERO
	velocity = Vector2.ZERO

func start():
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
	
	moving_around(null, 'side_to_side')


func _physics_process(delta):
	#print(global_position)
	#print(movepattern, moving, grounded, current_attack)
	if grounded != true && moving == true:
		if movepattern == 'static':
			velocity += accel*global_position.direction_to(movetarget)*delta
			if velocity.length() > speed:
				velocity = velocity.normalized()*speed
			position = position + velocity*delta
		if movepattern == 'side_to_side':
			var playpos = player.get_global_position()
			velocity += accel*global_position.direction_to(playpos + player.direction* 200+ Vector2(movsid, 500*mov)) *delta
			if global_position.distance_to((playpos + player.direction* 200)+ Vector2(movsid, 500*mov)) < 150:
				if playpos.x > global_position.x:
					movsid = 750
					if playpos.x + 850 > 3000:
						movsid = 3000 - playpos.x - 100
				else:
					movsid = -750
					if playpos.x - 850 < 0:
						movsid = -playpos.x + 100
			if velocity.length() > speed:
				velocity = velocity.normalized()*speed
		
			position = position + velocity*delta
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
	get_parent().restart()
		

func normaldie():
	pass

func truedeath():
	pass

func IFRAMES():
	I_FrameD = false



#actions
func attack(attack):
	if hp > 0:
		print(attack)
		if attack != 'wait':
			if attacks[attack][4] == true && grounded == false:

				flying(false, attack)
			elif attacks[attack][4] == false && grounded == true:
				if attack == 'swoop' || attack == 'fly':
					flying(true, attack, null, null, true)
				else:
					flying(true, attack)
			else:
				#$attacktime.wait_time = attacks[attack][0]
				#$attacktime.start()
				call(attack)
				
				if attacks[attack][4] == null && grounded == true:
					flying(true)
				attacking = true
				if attack == 'feather':
					moving_around(null, 'side_to_side')
		else:
			if grounded == false:
				flying(false)
			$waittimer.wait_time = 12 - 4*(pow(corruption, 2)/64)
			$waittimer.start()
			waiting = true
		last_attack = attack

func attack_end():
	if hp > 0:
		attacking = false
		if last_attack == 'screech'||last_attack == 'longscreech':
			screech = false
			player.stop_push()
		if last_attack == 'fly' || last_attack == 'swoop':
			landing()
			$AnimationPlayer.play('land')
		if last_attack != 'wait':
			yield(get_tree().create_timer(attacks[last_attack][2] - attacks[last_attack][2]*(corruption/12)), 'timeout')
		move(current_pattern)
	
	
	

func attackdelayend():
	pass # Replace with function body.

func move(pattern):
	if hp > 0:
		if attacking ==false:
			if !pattern.size() <= pattern_nr:
				var attack = pattern[pattern_nr]
				pattern_nr += 1
				attack(attack)
				#last_attack = attack
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
	yield(get_tree().create_timer(attacks['timer'][0]), 'timeout')
	if hp > 0:
		attack_end()
#attacks
func fly():
	moving = false
	movepattern = null
	mov  = null
	movsid = 0
	rng.randomize()
	var x = rng.randi_range(96, 2700)
	var y = rng.randi_range(256, 2700)
	$AnimationPlayer.play('fly_up')
	print('flying')
	landtarget = Vector2(x, y)
	yield(get_tree().create_timer(attacks['fly'][0]), 'timeout')
	if hp > 0:
		attack_end()
	
func landing():
	grounded = false
	moving = true
	global_position = landtarget
	moving_around(null, "rand")
	$hurtbox/CollisionShape2D.disabled = false

func swoop():
	if hp > 0:
		moving = false
		movepattern = null
		mov  = null
		movsid = 0
		rng.randomize()
		$Tween.interpolate_property($anim, 'modulate', modulate, Color(1, 1, 1, 0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()
		$hurtbox/CollisionShape2D.disabled = true
		var number = ceil(rng.randi_range(6, 8) + round(round(10 * pow(corruption, 2)/64))*  (2 - (hp/max_hp)))
		var lastx = []
		var lasty = []
		var aimed = ceil(number / 2  + 8 * pow(corruption, 2) / 64 * 2) + 1
		var unaimed = floor(number / 2  + 8 * pow(corruption, 2) / 64 * 2) - 1
		var lats = []
		var lastxis = ['x', 'x']
		for i in number:
			if hp < 0:
				return
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
						startpos.x = 3200 
						endpos.x = -200
					else:
						startpos.x = -200
						endpos.x = 3200
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
						startpos.y = 3200 
						endpos.y = -200
					else:
						startpos.y = -200
						endpos.y = 3200
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
						startpos.x = 3200 
						endpos.x = -200
					else:
						startpos.x = -200
						endpos.x = 3200
				else:
					dott = Vector2(0, 1)
					
					startpos.y = stepify(player.global_position.y, 200) + rng.randi_range(2, (ceil(lenth/200-7)))*-dir*200
					startpos.x = stepify(player.global_position.x, 200) + rng.randi_range(2, (ceil(lenth/200-7)))*-dir*200
					
					while lastx.has(startpos.x):
						startpos.x += (rng.randi_range(0, 1)*2 -1)*200
					endpos = startpos + Vector2(0, lenth)*dir
					if dir ==-1:
						startpos.y = 3200 
						endpos.y = -200
					else:
						startpos.y = -200
						endpos.y = 3200
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
		rng.randomize()
		var x = rng.randi_range(96, 2700)
		var y = rng.randi_range(256, 2700)
		if current_pattern.size() == pattern_nr+1:
			x = 1500
			y = 1500
		landtarget = Vector2(x, y)
		yield(get_tree().create_timer(4), "timeout")
		$Tween.interpolate_property($anim, 'modulate', Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()
		$hurtbox/CollisionShape2D.disabled = false
		if hp > 0:
			attack_end()


	
func screech():
	if hp > 0:
		print('ha')
		if corruption < 8:
			$anim.play('screech')
		else:
			$anim.play('corscreech')
		$AnimationPlayer.play("screetch")
		screech = true
		print(screech)
		player.push(self, 50000)
		yield(get_tree().create_timer(attacks['screech'][0]), 'timeout')
		if hp > 0:
			attack_end()
		

func longscreech():
	yield(get_tree().create_timer(attacks['longscreech'][0]), 'timeout')
	attack_end()

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
	yield(get_tree().create_timer(attacks['cross'][0]), 'timeout')
	if hp > 0:
		attack_end()

func feather():
	if hp > 0:
		var nru = 1
		if hp / max_hp * 100 >= 60:
			nru = 1
		elif hp / max_hp * 100>= 25:
			nru = 2
		elif hp / max_hp * 100>= 0:
			nru = 3
		print(nru)
		for h in range(4):
			if hp < 0:
				return
			for g in range(nru):
				for i in range(5):
					var feth = feather.instance()
					get_parent().add_child(feth)
					feth.position = $wingtip.global_position
					print(corruption)
					feth.summon(1200, Vector2(0, 1), 10, Vector2(0, 0), "feather", 'enemy', 0.4 - ((corruption-8.0)/32.0) + 0.2/nru, corruption)
					feth.look_at(get_parent().get_child(0).get_global_position()) 
					feth.rotate((i-2)*0.25)
				yield(get_tree().create_timer(0.3 +  0.3/nru), 'timeout')
			yield(get_tree().create_timer(2-(0.3 +  0.3/nru)), 'timeout')
		if hp > 0:
			attack_end()

func conferge():
	yield(get_tree().create_timer(attacks['conferge'][0]), 'timeout')
	attack_end()

func encircle():
	yield(get_tree().create_timer(attacks['encircle'][0]), 'timeout')
	attack_end()

func missile():
	for i in range(4):
		if hp > 0:
			$AnimationPlayer.play('missile')
			yield(get_tree().create_timer(0.9), 'timeout')
		else:
			return
	yield(get_tree().create_timer(attacks['missile'][0]-0.9*4), 'timeout')
	if hp > 0:
		attack_end()

func summon_missile():
	var miss = hissile.instance()
	get_parent().add_child(miss)
	miss.summon($beak.get_global_position(), corruption, player, 15)


func bomb():
	yield(get_tree().create_timer(attacks['bomb'][0]), 'timeout')
	attack_end()


#moving
func flying(airborn, attack = null, movingg = null, pat= null, away = false):
	if hp > 0:
		print('fly')
		if attacking != true:
			print('fly')
			if grounded == false && airborn == false:
				print('land')
				landing = true
				#$anim.play('land')
				if away == false:
					$Tween2.interpolate_property(self, 'position:y', position.y, position.y + 150, .4, Tween.TRANS_LINEAR, Tween.EASE_IN)
					$Tween2.start()
				else:
					pass
					#yield(get_tree().creat_trimer(0.2), 'timeout')
					#$Tween2.interpolate_property(self, 'position:y', position.y, position.y + 150, .4, Tween.TRANS_LINEAR, Tween.EASE_IN)
					#$#Tween2.start()
				grounded = true
				moving = false
				if corruption < 8:
					$anim.play('idle')
				else:
					$anim.play('coridle')
			elif grounded == true && airborn == true:
				print('fly')
				landing = false
				#$anim.play('fly_up')
				if away == false:
					$Tween2.interpolate_property(self, 'position:y', position.y, position.y - 150, .33, Tween.TRANS_LINEAR, Tween.EASE_IN)
					$Tween2.start()
				else:
					pass
					#yield(get_tree().creat_trimer(0.1), 'timeout')
					#$Tween2.interpolate_property(self, 'position:y', position.y, position.y - 150, .33, Tween.TRANS_LINEAR, Tween.EASE_IN)
					#$Tween2.start()
				grounded = false
				moving = true
				if corruption < 8:
					$anim.play('fly')
				else:
					$anim.play('corfly')
			if attack !=null:
				print('flyattack')
				yield(get_tree().create_timer(0.2), "timeout")
				print('cont')
				attack(attack)
				landing = false
			if movingg != null:
				print('flymove')
				yield(get_tree().create_timer(0.2), "timeout")
				moving_around(movingg, pat)
				landing = false
				moving = true
				grounded = false

func moving_around(target = null, patter = 'static'):
	if hp > 0:
		print(patter)
		rng.randomize()
		var pattern = patter
		var playpos = player.get_global_position()
		var tt = target
		if patter =='rand':
			if rng.randi_range(0, 2) == 1:
				pattern = 'static'
			else:
				pattern = 'size_to_side'
		print(tt)
		if tt == null:
			tt = Vector2(1500, 1500)
		if target == null&& pattern == 'static':
			tt =  playpos+Vector2((rng.randi_range(0, 1)*2-1)*750,(rng.randi_range(0, 1)*2-1)*750)
			if tt.x <100:
				tt.x = playpos.x+750
			elif tt.x >2900:
				tt.x = playpos.x-750
			if tt.y <200:
				tt.y = playpos.x+750
			elif tt.y >2900:
				tt.y = playpos.x-750
		if grounded == true:
			flying(true, null, tt, pattern)
		else:
			if tt == null:
				tt = Vector2(1500, 1500)
			if target == null&& pattern == 'static':
				tt =  playpos+Vector2((rng.randi_range(0, 1)*2-1)*750,(rng.randi_range(0, 1)*2-1)*750)
				if tt.x <100:
					tt.x = playpos.x+750
				elif tt.x >2900:
					tt.x = playpos.x-750
				if tt.y <200:
					tt.y = playpos.x+750
				elif tt.y >2900:
					tt.y = playpos.x-750
			if pattern == 'static':
				movetarget = tt
			if pattern == 'side_to_side':
				
				if playpos.y < 728:
					mov = 1
				else:
					mov = -1
				if playpos.x > global_position.x:
					movsid = 500
					if playpos.x + 600 > 3000:
						movsid = 3000 - playpos.x - 100
				else:
					movsid = -500
					if playpos.x - 600 < 0:
						movsid = -playpos.x + 100
			
			movepattern = pattern
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
	print(body)
	if  body.is_in_group('player_weapons'):
		hurt(1)
	if  body.is_in_group('explosions'):
		hurt(2)


func _on_waittimer_timeout():
	$short.stop()
	$waittimer.stop()
	move(current_pattern)
	waiting = false
	threshold = 0


func _on_Area2D_body_entered():
	start()
	get_parent().get_child(1).get_child(0).set_deferred('disabled', true)
		
