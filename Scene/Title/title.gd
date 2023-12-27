extends Node

@onready var titlePlayer:AnimationPlayer = $%TitlePlayer
var is_title_menu:bool = false
var is_title_init:bool = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_title_init_animation()

func _process(_delta: float) -> void:
	
	if is_title_init and Input.is_anything_pressed():
		if not is_title_menu :
			play_title_press_enter()
		else:
			play_title_menu()

func play_title_init_animation() -> void:
	titlePlayer.play("TitleInitAnimation")

func play_title_press_enter() -> void:
	titlePlayer.play("TitlePressEnter")
	is_title_menu = true

func play_title_menu() -> void:
	is_title_init = false
	titlePlayer.play("TitleMenu")
