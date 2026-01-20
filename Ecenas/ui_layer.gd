extends CanvasLayer

var buttonContainer: HBoxContainer

@onready var restart_button = $%Restart
@onready var quit_button = $%Quit
@onready var game_over_label = $GameOverLabel
@onready var points_label = $PoinstLabel
@onready var snake_reset: AudioStreamPlayer = $SnakeReset

@onready var snake: Snake = $"../Snake"

func _ready():
	snake_reset.play()
	snake.on_game_over.connect(on_game_over)
	snake.on_point_socred.connect(on_point_scored)
	buttonContainer = get_node("BoxContainer")
	quit_button.pressed.connect(on_quit_button_pressed)
	
func on_game_over():
	buttonContainer.visible = true
	game_over_label.visible = true

func on_point_scored(points: int):
	points_label.text = "Poinst: %d" % points

func _on_restart_pressed():
	get_tree().reload_current_scene()

func on_quit_button_pressed():
	get_tree().quit()

