extends KinematicBody2D

#movement
const speed = 20000
const acceleration = 100000
export(int) var dashspeed = 15000
const dashtime = 0.25
const dash_delay = 0.5
var can_dash = true

#health
const I_frames = 0.5
const max_hp = 9
var hp

#physics
var velocity = Vector2.ZERO
var direction = Vector2.ZERO
var force_direction
#state
var states = ['idle', "walk", "dash", "dropdash", "dead"]
var state = "idle" setget statemachine, getstate


#combat
var weapons = ["shortsword"]
var current_weapon = "shortsword"
var current_weapon_nr = 1
var oldweapon_nr = 1
var is_attacking = false
const weapon_switch_delay = 0.25
var switching_weapons = false

#[origin, force]
var push = null
var knockback = 0

#weapons
onready var weapon1 = preload("res://player/weapons/sword.tscn")
onready var weapon2 = preload("res://player/weapons/bow.tscn")
onready var weapon3 = preload("res://player/weapons/sword.tscn")
onready var weapon4 = preload("res://player/weapons/sword.tscn")
onready var weapon5 = preload("res://player/weapons/sword.tscn")
onready var weapon6 = preload("res://player/weapons/sword.tscn")
onready var weapon7 = preload("res://player/weapons/sword.tscn")
onready var weapon8 = preload("res://player/weapons/sword.tscn")
onready var weapon9 = preload("res://player/weapons/sword.tscn")
var knockk = false


#ready
func _ready():
	hp = max_hp
	for i in get_tree().get_nodes_in_group('health'):
		i.hp(hp)
	#I_FRAMES(5.0)
	for i in range(1,10):
		var wap = get("weapon" + String(i)).instance()
		$weapons.add_child(wap)
		wap.global_position = $weaponaccess/weaponpos.global_position
		wap.player = self
		if i != current_weapon_nr:
			wap.visible = false
func ready():
	hp = max_hp
	for i in get_tree().get_nodes_in_group('health'):
		i.hp(hp)
	global_position = Vector2(1580, 3400)
	#I_FRAMES(5.0)
	can_dash = true
	velocity = Vector2.ZERO
	direction = Vector2.ZERO
	is_attacking = false
	switching_weapons = false
	push = null


#physics
func _physics_process(delta):

	if knockk == false:
		$weapons.look_at(get_global_mouse_position())
		var force = Vector2.ZERO
		if push != null:
			var dir = ( push[0].get_global_position() - self.get_global_position() ).normalized()
			var dis = get_global_position().distance_to(push[0].get_global_position())
			var dist = 0
			if dis < 500:
				dist = (600 -dis)/500 +0.05
			force = dir * dist * push[1]
			
		if state != 'walk':
			if $AnimatedSprite.playing ==true:
				$AnimatedSprite.stop()
		if state == "walk":
			velocity = (direction.normalized() * speed - force) * delta 
			velocity = move_and_slide(velocity)
			if velocity.y >0:
				if $AnimatedSprite.animation == "back" || ($AnimatedSprite.animation== "front"&&$AnimatedSprite.playing ==false):
					if $AnimatedSprite.playing ==true:
						$AnimatedSprite.stop()
					$AnimatedSprite.play("front")
			if velocity.y <0:
				if $AnimatedSprite.animation == "front"||($AnimatedSprite.animation== "back"&&$AnimatedSprite.playing ==false):
					if $AnimatedSprite.playing ==true:
						$AnimatedSprite.stop()
					$AnimatedSprite.play("back")
		elif state == "hurt":
			pass
		elif state == "dash":
			#velocity -= acceleration * delta * direction
			velocity = (direction * dashspeed) * delta

			#velocity = move_and_slide(velocity)
		elif push != null:
			velocity =  -force * delta
			#velocity = move_and_slide(velocity)
		elif state == 'idle':
			velocity = Vector2(0, 0)
	else:
		velocity =  knockback * force_direction * delta * 1000
		if knockback>0:
			knockback += delta * -200
	velocity = move_and_slide(velocity)



#controls
func _input(event):
#moving
	if state == "idle" || state == "walk":
		if Input.is_action_pressed("ui_down"):
			direction.y = 1
			if state == 'idle':
				state = "walk"
		elif Input.is_action_pressed("ui_up"):
			direction.y = -1
			if state == 'idle':
				state = "walk"
		else:
			direction.y = 0
		if Input.is_action_pressed("ui_left"):
			direction.x = -1
			if state == 'idle':
				state = "walk"
		elif Input.is_action_pressed("ui_right"):
			direction.x = 1
			if state == 'idle':
				state = "walk"
		else:
			direction.x = 0
		if direction.x == 0 && direction.y == 0:
			state = "idle"


#dash
		if !is_attacking && knockk == false:
			if Input.is_action_just_pressed("dash") && can_dash:
				dash_start()


#attacking
		if Input.is_action_just_pressed("attack") && is_attacking == false && switching_weapons == false:
			attack()


#weapons
		if !switching_weapons && !is_attacking:
			var wapsize = weapons.size()
			if Input.is_action_just_pressed("1"):
				if current_weapon_nr != 1:
					current_weapon_nr = 1
					switching_weapons = true
			elif wapsize > 1:
				if Input.is_action_just_pressed("2"):
					if current_weapon_nr != 2:
						current_weapon_nr = 2
						switching_weapons = true
				elif wapsize > 2:
					if Input.is_action_just_pressed("3"):
						if current_weapon_nr != 3:
							current_weapon_nr = 3
							switching_weapons = true
					elif wapsize > 3:
						if Input.is_action_just_pressed("4"):
							if current_weapon_nr != 4:
								current_weapon_nr = 4
								switching_weapons = true
						elif wapsize > 4:
							if Input.is_action_just_pressed("5"):
								if current_weapon_nr != 5:
									current_weapon_nr = 5
									switching_weapons = true
							elif wapsize > 5:
								if Input.is_action_just_pressed("6"):
									if current_weapon_nr != 6:
										current_weapon_nr = 6
										switching_weapons = true
								elif wapsize > 6:
									if Input.is_action_just_pressed("7"):
										if current_weapon_nr != 7:
											current_weapon_nr = 7
											switching_weapons = true
									elif wapsize > 7:
										if Input.is_action_just_pressed("8"):
											if current_weapon_nr != 8:
												current_weapon_nr = 8
												switching_weapons = true
										elif wapsize > 8:
											if Input.is_action_just_pressed("9"):
												if current_weapon_nr != 9:
													current_weapon_nr = 9
													switching_weapons = true
			if switching_weapons == true:
				current_weapon = $weapons.get_child(current_weapon_nr).named
				$weapons.get_child(oldweapon_nr).visible = false
				$weapons.get_child(current_weapon_nr).visible = true
				$weaponaccess/weapon_switch.wait_time = weapon_switch_delay
				$weaponaccess/weapon_switch.start()
				oldweapon_nr = current_weapon_nr


#mouse




#attack + weapons
func attack():
	is_attacking = true
	#gets specific weapon data
	var weapon = $weapons.get_child(weapons.find(current_weapon)+1) 
	weapon.attack(get_local_mouse_position())
	$weapons/swingdelay.wait_time = weapon.delay
	$weapons/swingdelay.start()

func _on_swingdelay_timeout():
	if Input.is_action_pressed("attack"):
		attack()
	is_attacking = false

func _on_weapon_switch_timeout():
	switching_weapons = false

func weapon_switch(new_value):
	pass





#dash
func dash_start():
	is_attacking = true
	$weapons/swingdelay.wait_time = dashtime * 2.0
	$weapons/swingdelay.start()
	state = "dash"
	velocity = direction * dashspeed
	print(direction, 'dasj')
	print(velocity)
	$dash/dash.wait_time = dashtime
	$dash/dash_delay.wait_time = dash_delay
	$dash/dash_delay.start()
	can_dash = false
	#print(dashtime)
	$dash/dash.start()
	$dash/AnimationPlayer.play("dash")
	

func dash_end():
	state = "walk"
	_input('joke')
	
func dash_delay_timeout():
	can_dash = true






#statemachine
func getstate():
	return state

func statemachine(new_value):
	state = new_value
	print(new_value)
	if new_value == "idle" || "dead":
		
		direction = Vector2.ZERO
		velocity = Vector2.ZERO
		if new_value == "dead":
			death()





#taking damage
func hurt(heal):
	if hp> 0:
		$hurtbox/CollisionShape2D.set_deferred('disabled',true)
		hp = hp - heal
		$dash/AnimationPlayer.play('hurt')
		#print(hp)
		for i in get_tree().get_nodes_in_group('health'):
			i.hp(hp)
		if hp == 0:
			state = 'dead'
		I_FRAMES(I_frames)

func death():
	#print('gea')
	$AnimatedSprite.stop()
	get_parent().restart(true)
	$AnimatedSprite.play("death")

func _on_hurtbox_body_entered(body):

	if body.is_in_group('feather') or body.is_in_group('explosion') or body.is_in_group('enemy'):
		print(body.get_groups())
		if !body.is_in_group('rocket'):
			hurt(1)
			$hurtbox/CollisionShape2D.set_deferred('disabled',true)
			if body.is_in_group('explosion'):
				#print('hiss')
				body.get_parent().get_parent().hit()
				knock(body.get_global_position(), 0.6)
			else:
				controller.shake(0.2, 0.7)
			if body.is_in_group('enemy'):
				body.hit()
			controller._freeze_frame( 0,0.1)
	




#IFRAMES
func I_FRAMES(time):
	$I_FRAMES.wait_time = time
	$I_FRAMES.start()
	$hurtbox/CollisionShape2D.set_deferred('disabled',true)

func I_frames_end():
	$hurtbox/CollisionShape2D.set_deferred('disabled',false)



func push(origin, force):
	push = [origin, force]
func stop_push():
	push = null



func knock(orientation, force = 40):
	knockk = true

	force_direction = (global_position - orientation).normalized()#Vector2(cos(ori*PI), sin(ori*PI))
	print(direction)
	knockback = 50
	yield(get_tree().create_timer(.25), 'timeout')
	knockk = false
