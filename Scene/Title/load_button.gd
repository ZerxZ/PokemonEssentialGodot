extends TextureButton

@onready var animation: AnimationPlayer = $%AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation.play("walk")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
