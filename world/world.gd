extends Node2D

var corruption = 0
var cormax = 9
onready var worl0 = preload('res://world/corruption_0.tscn')
onready var worl1 = preload('res://world/corruption_1.tscn')
onready var worl2 = preload('res://world/corruption_2.tscn')
onready var worl3 = preload('res://world/corruption_3.tscn')
onready var worl4 = preload('res://world/corruption_4.tscn')
onready var worl5 = preload('res://world/corruption_5.tscn')
onready var worl6 = preload('res://world/corruption_6.tscn')
onready var worl7 = preload('res://world/corruption_7.tscn')
onready var worl8 = preload('res://world/corruption_8.tscn')




func _ready():
	ready()

func ready():
	$Camera2D2/CanvasLayer/ColorRect.get_material().set_shader_param("brightness", 0)
	$Tween2.interpolate_property($Camera2D2/CanvasLayer/ColorRect.get_material(), "shader_param/brightness", 2, 0, 2, Tween.TRANS_CIRC, Tween.EASE_OUT)
	$Tween2.start()
	for i in $worldd.get_children():
		$worldd.get_child(0).queue_free()
	var world = get('worl'+String(corruption)).instance()
	$worldd.add_child(world)
	reset()
	

func dialog_end():
	$Camera2D2.target = "../player"
	$Tween.interpolate_property($Camera2D2, 'zoom', Vector2(0.7,0.7), Vector2(1.0, 1.0), 0.4, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	$owl_big2._on_Area2D_body_entered()
	

func reset():
	pass

func restart():
	$Tween2.interpolate_property($Camera2D2/CanvasLayer/ColorRect.get_material(), "shader_param/brightness", 0, 5, 2, Tween.TRANS_CIRC, Tween.EASE_IN)
	$Tween2.start()
	corruption += 1
	if corruption > 1:
		corruption += 1
	if corruption == 7:
		corruption += 1
	yield(get_tree().create_timer(5), 'timeout')
	ready()
	$owl_big2.ready()
	$player.ready()


func _on_Area2D_body_entered(body):
	if body.is_in_group('trueplayer'):
		$dialog.dialog(corruption)
		$Tween.interpolate_property($Camera2D2, 'zoom', Vector2(1.0,1.0), Vector2(0.7, 0.7), 0.8, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
		$Camera2D2.target  = "../nest"
