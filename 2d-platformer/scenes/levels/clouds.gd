extends ParallaxLayer

func _ready() -> void:
	pass # Replace with function body.

@export var CLOUD_SPEED: float = -15.0

func _process(delta) -> void:
	#control how the clouds moved.
	self.motion_offset.x += CLOUD_SPEED * delta
