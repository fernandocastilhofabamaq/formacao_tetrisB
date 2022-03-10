extends Node2D

onready var Game_Over_Sound:AudioStreamPlayer2D=get_node("Game_Over_Sound")

func PlaySound():
	Game_Over_Sound.play()


