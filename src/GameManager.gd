extends Node2D
onready var Bg_music:AudioStreamPlayer2D=get_node("BG_Music")




# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func PlaySound():
	Bg_music.play()
	

	
	

