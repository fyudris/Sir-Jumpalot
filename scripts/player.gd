extends CharacterBody2D

const SPEED = 130.0
const ROLL_SPEED = 200.0  # Speed during roll
const JUMP_VELOCITY = -300.0
const ROLL_DURATION = 0.5  # Duration of the roll in seconds

var is_rolling = false
var roll_timer = 0.0  # Tracks how long the player has been rolling
var roll_direction = 1  # Direction in which the player is rolling (-1 for left, 1 for right)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get input direction: -1, 0, 1
	var direction := Input.get_axis("move_left", "move_right")

	# Handle roll input
	if Input.is_action_just_pressed("roll") and is_on_floor() and not is_rolling:
		is_rolling = true
		roll_timer = ROLL_DURATION
		
		# Set the roll direction based on player input
		if direction != 0:
			roll_direction = direction
		else:
			# If no input, use current sprite facing direction
			roll_direction = -1 if animated_sprite.flip_h else 1  # Correct ternary operator

		animated_sprite.play("roll")

	# Handle jump (disable jump during roll)
	if not is_rolling and Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_sfx.play()

	# Handle rolling state
	if is_rolling:
		roll_timer -= delta
		if roll_timer <= 0.0:
			is_rolling = false  # Stop rolling when the duration ends
		else:
			# Move faster during roll in the roll direction
			velocity.x = roll_direction * ROLL_SPEED
			# Flip the sprite based on the rolling direction
			animated_sprite.flip_h = roll_direction < 0
	
	else:
		# Normal movement (when not rolling)
		# Flip Sprite
		if direction > 0:
			animated_sprite.flip_h = false
		elif direction < 0:
			animated_sprite.flip_h = true
		
		# Play animations
		if is_on_floor():
			if direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
		else:
			animated_sprite.play("jump")
		
		# Apply movement
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
