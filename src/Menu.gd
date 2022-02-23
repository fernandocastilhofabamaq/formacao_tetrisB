extends Polygon2D

var res = [
	load("res://src/blocks/Block_I.tscn"),
	load("res://src/blocks/Block_L.tscn"),
	load("res://src/blocks/Block_Q.tscn"),
	load("res://src/blocks/Block_R.tscn"),
	load("res://src/blocks/Block_SL.tscn"),
	load("res://src/blocks/Block_SR.tscn"),
	load("res://src/blocks/Block_T.tscn")
]
var blocks = []
var active = []
var rng = RandomNumberGenerator.new()

export var speed = 15.0

func fill_blocks():
	blocks.clear()
	for block in res:
		blocks.append(block.instance())
	blocks.shuffle()

func on_spawn_next():
	if blocks.empty():
		fill_blocks()
	var next = blocks.pop_back()
	
	next.z_index=15
	next.rotation = rng.randf()*2*PI
	next.position += Vector2(rng.randf()*500-500,0)
	
	active.push_back(next)
	self.add_child(next)

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	fill_blocks()
	$Timer.connect("timeout", self, "on_spawn_next")
	$Button.connect("button_down", self, "on_start_game")
	on_spawn_next()
	$Timer.start()

func on_start_game():
	self.visible = false
	$Timer.stop()
	while !active.empty():
		self.remove_child(active.pop_back())
	get_node("../Gameboard/Timer").start()	

func _process(delta):
	var offset = Vector2(0,1)*speed*delta
	for shape in active:
		shape.position += offset
	
	if !active.empty() && active.front().position.y > 1000:
		var last = active.pop_front()
		self.remove_child(last)
		
