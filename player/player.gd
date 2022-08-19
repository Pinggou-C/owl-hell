extends KinematicBody2D

#movement
const speed = 25000
const acceleration = 400000
export(int) var dashspeed = 0
const dashtime = 0.25
const dash_delay = 0.666
var can_dash = true

#health
const I_frames = 0.25
const max_hp = 10
var hp

#physics
var velocity = Vector2.ZERO
var direction = Vector2.ZERO

#state
var states = ['idle', "walk", "dash", "dropdash", "dead"]
var state = "idle" setget statemachine, getstate


#combat
var weapons = ["shortsword", 'shortbow']
var current_weapon = "shortsword"
var current_weapon_nr = 1
var oldweapon_nr = 1
var is_attacking = false
const weapon_switch_delay = 0.25
var switching_weapons = false


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



#ready
func _ready():
	hp = max_hp
	I_FRAMES(5.0)
	for i in range(1,10):
		var wap = get("weapon" + String(i)).instance()
		$weapons.add_child(wap)
		wap.position = $weaponaccess/weaponpos.position
		wap.player = self
		if i != current_weapon_nr:
			wap.visible = false
			print(wap)



#physics
func _physics_process(delta):
	$weapons.look_at(get_global_mouse_position())
	if state != 'walk':
		if $AnimatedSprite.playing ==true:
			$AnimatedSprite.stop()
	if state == "walk":
		velocity = direction.normalized() * speed * delta
		velocity = move_and_slide(velocity)
		if velocity.y >0:
			print(2)
			if $AnimatedSprite.animation == "back" || ($AnimatedSprite.animation== "front"&&$AnimatedSprite.playing ==false):
				if $AnimatedSprite.playing ==true:
					$AnimatedSprite.stop()
				$AnimatedSprite.play("front")
		if velocity.y <0:
			print(3)
			if $AnimatedSprite.animation == "front"||($AnimatedSprite.animation== "back"&&$AnimatedSprite.playing ==false):
				if $AnimatedSprite.playing ==true:
					$AnimatedSprite.stop()
				$AnimatedSprite.play("back")
	elif state == "hurt":
		pass
	elif state == "dash":
		#velocity -= acceleration * delta * direction
		velocity = direction.normalized() * dashspeed * delta
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
		if !is_attacking:
			if Input.is_action_just_pressed("dash") && can_dash:
				dash_start()


#attacking
		if Input.is_action_just_pressed("attack") && is_attacking == false && switching_weapons == false:
			attack()


#weapons
		if !switching_weapons && !is_attacking:
			var wapsize = weapons.size()
			if Input.is_action_just_pressed("1"):
				print('1')
				if current_weapon_nr != 1:
					print('1.1')
					current_weapon_nr = 1
					switching_weapons = true
			elif Input.is_action_just_pressed("2"):
				print('2')
				if current_weapon_nr != 2:
					print('2.1')
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
				print(0.1)
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
	$dash/dash.wait_time = dashtime
	$dash/dash_delay.wait_time = dash_delay
	$dash/dash_delay.start()
	can_dash = false
	print(dashtime)
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
	if new_value == "idle" || "dead":
		direction = Vector2.ZERO
		velocity = Vector2.ZERO
		if new_value == "dead":
			death()





#taking damage
func hurt():
	I_FRAMES(I_frames)

func death():
	$AnimatedSprite.stop()
	$AnimatedSprite.play("death")

func _on_hurtbox_body_entered(body):
	if body.is_in_group('bullet'):
		hurt()




#IFRAMES
func I_FRAMES(time):
	$I_FRAMES.wait_time = time
	$I_FRAMES.start()
	$hurtbox/CollisionShape2D.disabled = true

func I_frames_end():
	$hurtbox/CollisionShape2D.disabled = false




