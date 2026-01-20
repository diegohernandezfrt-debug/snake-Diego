extends Node
class_name FoodSpawner
@export var walls: Walls
@export var food_scene: PackedScene

#Textura de comida
@export var food_normal: Texture2D
@export var food_gold: Texture2D
@export var food_speed: Texture2D

var food_position: Vector2

var food: Sprite2D


const BODY_SEGMENT_SIZE = 32

enum FoodType {
	NORMAL,
	GOLD,
	SPEED
}

var food_data = {
	FoodType.NORMAL: {
		"points": 1,
		"speed_multiplier": 1.0
	},
	FoodType.GOLD: {
		"points": 3,
		"speed_multiplier": 1.0
	},
	FoodType.SPEED: {
		"points": 2,
		"speed_multiplier": 1.5
	}
}
var food_textures = {}

var current_food_type: FoodType

func _ready():
	food_textures = {
		FoodType.NORMAL: food_normal,
		FoodType.GOLD: food_gold,
		FoodType.SPEED: food_speed
	}
	spawn_food()
	food.texture = food_textures[current_food_type]

func spawn_food():
	if food:
		food.queue_free()
		
	food = food_scene.instantiate()
	current_food_type = food_data.keys().pick_random()
	food.texture = food_textures[current_food_type]
	
	# Regresa lso valores aleatorios con 32 incrementos 
	var x_pos = round(randi_range(walls.top_left_corner.x + BODY_SEGMENT_SIZE, walls.bottom_right_corner.x - BODY_SEGMENT_SIZE) / BODY_SEGMENT_SIZE) * BODY_SEGMENT_SIZE
	var y_pos = round(randi_range(walls.top_left_corner.y + BODY_SEGMENT_SIZE, walls.bottom_right_corner.y - BODY_SEGMENT_SIZE) / BODY_SEGMENT_SIZE) * BODY_SEGMENT_SIZE
	add_child(food)
	food_position = Vector2(x_pos, y_pos)
	food.position = food_position
	add_child(food)
	
func destroy_food():
	if food != null:
		food.queue_free()
	
