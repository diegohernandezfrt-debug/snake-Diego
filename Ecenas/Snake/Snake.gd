class_name Snake

extends Node2D

@onready var eat_sound: AudioStreamPlayer2D = $EatSound
@onready var eat_sound_gold: AudioStreamPlayer2D = $EatSoundGold
@onready var snake_atak: AudioStreamPlayer2D = $SnakeAtak
@onready var game_over: AudioStreamPlayer = $GameOver

const BODY_SEGMENT_SIZE = 32

signal on_point_socred(points: int)
signal on_game_over

var points = 0

var base_speed := 0.15
@onready var speed_timer: Timer = $SpeedTimer

enum CollisionDirection {
	TOP,
	BOTTOM,
	LEFT,
	RIGHT
}

var body_parts = [ ]
var body_texture = preload("res://assets/Snake.png")
@onready var snake_parts: Node = $SnakeParts
@onready var timer = $Timer

var food_spawmer : FoodSpawner

# Walls o muros 
@export var walls: Walls
var walls_dict

#variable para el movimiento de snake
var move_direction = Vector2.ZERO

func _ready():
	
	var head = Sprite2D.new()
	head.position = Vector2(0,0)
	head.scale = Vector2(1,1)
	head.texture = body_texture
	snake_parts.add_child(head)
	body_parts.append(head)
	#Timer
	timer.timeout.connect(on_timeout)
	walls_dict = walls.walls_dict
	food_spawmer = get_tree().get_first_node_in_group("food_spawner") as FoodSpawner
	
	
func _process(delta: float):
	pass

func _input(event):
	if ((event.is_action_pressed("ui_right") || event.is_action_pressed("right")) && move_direction.x != -1):
		move_direction = Vector2.RIGHT
	elif ((event.is_action_pressed("ui_left") || event.is_action_pressed("left")) && move_direction.x != 1):
		move_direction = Vector2.LEFT
	elif ((event.is_action_pressed("ui_up") || event.is_action_pressed("up")) && move_direction.y != 1):
		move_direction = Vector2.UP
	elif ((event.is_action_pressed("ui_down") || event.is_action_pressed("down")) && move_direction.y != -1):
		move_direction = Vector2.DOWN
		
func apply_speed_boost(multiplier: float):
	speed_timer.stop() # evita acumulaciones
	timer.wait_time = base_speed / multiplier
	speed_timer.start(10)

func _on_speed_timer_timeout():
	timer.wait_time = base_speed

func on_timeout():
	var new_head_position = position + move_direction * BODY_SEGMENT_SIZE
	# Paredes de colision
	var wall_collision = check_wall_collision(new_head_position)
	if wall_collision == null:
		move_to_position(new_head_position)
	else: 
		var position_after_wall_collision = get_position_after_wall_collision(wall_collision, new_head_position)
		new_head_position = position_after_wall_collision
		move_to_position(position_after_wall_collision)
		
	#Colission con la comida
	if  new_head_position == food_spawmer.food_position:
		var data = food_spawmer.food_data[food_spawmer.current_food_type]
		
		points += data["points"]
		on_point_socred.emit(points)
		if data["speed_multiplier"] > 1.0:
			apply_speed_boost(data["speed_multiplier"])
		
		food_spawmer.destroy_food()
		food_spawmer.spawn_food()
		add_body_part()
		#audio de rata
		if food_spawmer.current_food_type == FoodSpawner.FoodType.NORMAL || food_spawmer.current_food_type == FoodSpawner.FoodType.SPEED:
			eat_sound.play()
		else:
			eat_sound_gold.play()
		snake_atak.play()
		


#check collision snake
	var snake_collision = check_snake_collision(new_head_position)
	if snake_collision:
		timer.stop()
		on_game_over.emit()
		#audio game over
		game_over.play()

func move_to_position(new_position):
	
	if body_parts.size() > 1:
		var last_element = body_parts.pop_back()
		last_element.position = body_parts[0].position
		body_parts.insert(1, last_element)
	
	print_debug(new_position)
	position = new_position
	body_parts[0].position = new_position

func check_wall_collision(new_head_position: Vector2):
	if new_head_position.x == walls_dict["left"].position.x && move_direction == Vector2.LEFT:
		return CollisionDirection.LEFT
	elif new_head_position.x == walls_dict["right"].position.x && move_direction == Vector2.RIGHT:
		return CollisionDirection.RIGHT
	elif new_head_position.y == walls_dict["top"].position.y && move_direction == Vector2.UP:
		return CollisionDirection.TOP
	elif new_head_position.y == walls_dict["bottom"].position.y && move_direction == Vector2.DOWN:
		return CollisionDirection.BOTTOM

func get_position_after_wall_collision(wall_collision: CollisionDirection, new_head_position: Vector2):
	if (wall_collision == CollisionDirection.LEFT || wall_collision == CollisionDirection.RIGHT) && new_head_position.y <= 0:
		move_direction = Vector2.DOWN
	elif (wall_collision == CollisionDirection.LEFT || wall_collision == CollisionDirection.RIGHT) && new_head_position.y > 0:
		move_direction = Vector2.UP
	elif (wall_collision == CollisionDirection.TOP || wall_collision == CollisionDirection.BOTTOM) && new_head_position.x <= 0:
		move_direction = Vector2.RIGHT
	elif (wall_collision == CollisionDirection.TOP || wall_collision == CollisionDirection.BOTTOM) && new_head_position.x > 0:
		move_direction = Vector2.LEFT
	return body_parts[0].position + move_direction * BODY_SEGMENT_SIZE

func add_body_part():
	var new_part = Sprite2D.new()
	new_part.texture = body_texture
	snake_parts.add_child(new_part)
	new_part.scale = Vector2(.9, .9)
	new_part.position = body_parts[-1].position - move_direction * BODY_SEGMENT_SIZE
	body_parts.append(new_part)

func check_snake_collision(new_head_position):
	var body_parts_without_head = body_parts.slice(1, body_parts.size())
	if body_parts_without_head.filter(func (part): return part.position == position):
		return true
	return false
