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
var blocks = [];
var move_down = true;
var preview
var active;
var retired;
var block_area_origin;
var game_over = false;

var points
var points_label
var next_level

func fill_blocks():
	blocks.clear()
	for block in res:
		blocks.append(block.instance())
	blocks.shuffle()

func retire():
	for block in active.get_children():
		var pos = (block_area_origin - block.global_position).round()/32
		
		if pos.y >= retired.rows:
			return true # block is over top, game over
		
		var new_parent = KinematicBody2D.new()
		self.add_child(new_parent)
		new_parent.position = active.position
		new_parent.rotation = active.rotation
		
		active.remove_child(block)
		new_parent.add_child(block)
		
		retired.add(pos.y, new_parent)
	return false

func check_rows():
	var completed = []
	for r in range(retired.rows):
		if retired.is_complete(r):
			completed.push_back(r)
			
	var num_completed = completed.size()
	
	while !completed.empty():
		var completed_row = completed.pop_back()
		for block in retired.remove(completed_row):
			block.get_parent().remove_child(block)
		for shift_idx in range(completed_row, retired.rows):
			for block in retired.get_row(shift_idx):
				block.position += Vector2(0, 32)
	
	return num_completed

func spawn_next():
	if blocks.empty():
		fill_blocks()
	active = preview.get_child(0)
	preview.remove_child(active)
	preview.add_child(blocks.pop_back())
	
	self.add_child(active)
	active.set_position(Vector2(-240,-720))
	
func move_or_return(object, location):
	var collision = object.move_and_collide(location)
	if collision != null:
		object.move_and_collide(-collision.travel)
		# we don't want to report a collision when we hit the wall,
		# otherwise we could retire a block on the wall
		return collision.collider.name != "Walls"
	return false

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$Timer.connect("timeout", self, "on_timer_signal")
	$Timer.wait_time = 0.5
	preview = get_node("Background/PreviewArea")
	points = 0
	points_label = get_node("Background/Points/Points")
	next_level = 250
	fill_blocks()
	preview.add_child(blocks.pop_back())
	spawn_next()
	block_area_origin = self.global_position - Vector2(16, 16)
	retired = BlockMap.new(23,15)
	print("ready")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_over:
		return
	
	var move_to = Vector2(0,0)
	if Input.is_action_just_pressed("ui_left"):
		move_to += Vector2(-32,0)
	if Input.is_action_just_pressed("ui_right"):
		move_to += Vector2(32,0)
		
	if Input.is_action_just_pressed("ui_down"):
		$Timer.wait_time /= 2;
	if Input.is_action_just_released("ui_down"):
		$Timer.wait_time *= 2;
		
	if Input.is_action_just_pressed("ui_up"):
		active.rotate(deg2rad(90))
	
	move_or_return(active, move_to)
	
	if !move_down:
		return
	
	move_to += Vector2(0,32)
	move_down = false;
	if move_or_return(active, move_to):
		if retire():
			game_over = true
			print("game over")
			return
		
		match check_rows():
			1: points += 100
			2: points += 250
			3: points += 750
			4: points += 1000
		points_label.text = "%d" % points
		if points >= next_level and $Timer.wait_time > 0.1:
			next_level *= 2
			$Timer.wait_time -= 0.1
		
		for block in retired.get_row(retired.rows-1):
			var pos = (block_area_origin - block.global_position).round()/32
			if pos.x == 7:
				print("game over")
				game_over = true;
				return
		spawn_next()

func on_timer_signal():
	move_down = true;


class BlockMap:
	var blocks = []
	var rows
	var cols
	
	func _init(rows, cols):
		self.rows = rows
		self.cols = cols
		for n in range(self.rows):
			self.blocks.push_back([])
	
	func add(row, obj):
		self.blocks[row].push_back(obj)
		
	func is_complete(row):
		return self.blocks[row].size() == self.cols
	
	func remove(row):
		var r = self.blocks[row]
		self.blocks.remove(row)
		self.blocks.push_back([])
		return r
	
	func get_row(row):
		return self.blocks[row]
