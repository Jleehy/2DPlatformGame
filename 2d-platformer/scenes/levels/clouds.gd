extends ParallaxLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.

@export var CLOUD_SPEED: float = -15.0

func _process(delta) -> void:
	self.motion_offset.x += CLOUD_SPEED * delta
