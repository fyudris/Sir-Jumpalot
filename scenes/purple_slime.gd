extends Node2D

const SPEED = 60

var direction = 1  # 1 for right, -1 for left

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_wall: RayCast2D = $RayCast_wall  # Facing right
@onready var ray_cast_down: RayCast2D = $RayCast_down  # Pointing down, slightly ahead when moving left

func _physics_process(delta: float) -> void:
	# Check for wall collision on the right and flip direction if colliding
	if ray_cast_wall.is_colliding() and direction == 1:
		direction = -1
		animated_sprite.flip_h = true
	
	# Check for edge of the cliff on the left (no ground detected)
	if not ray_cast_down.is_colliding() and direction == -1:
		direction = 1
		animated_sprite.flip_h = false
	
	# Move the slime in the current direction
	position.x += direction * SPEED * delta
