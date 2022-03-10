extends Node2D

onready var Game_Won_Sound:AudioStreamPlayer2D=get_node("Game_Won_Sound")

func PlaySound():
	Game_Won_Sound.play()
