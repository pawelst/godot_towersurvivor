extends CharacterBody2D

var player
var health = 30
var speed = 20
var is_dying = false

@onready var animation_orc = $AnimatedSprite2D
@onready var sprite_frames = $AnimatedSprite2D.sprite_frames # Access the SpriteFrames resource
@export var coin_scene = preload("res://scenes/coin.tscn") # Preload the coin scene
@onready var hit_timer = Timer.new()

func _ready():
	animation_orc.animation_finished.connect(_on_animated_sprite_2d_animation_finished)
	player = get_node("/root/Game/Player")
	update_animation_direction(player.global_position)
	add_to_group("enemies")
	print_debug("Groups for this enemy: ", get_groups())
	
	add_child(hit_timer) # Add the timer to the orc node
	hit_timer.one_shot = true
	hit_timer.wait_time = 0.2 # Time for how long the glow should last

func _physics_process(delta: float):
	if not is_dying:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		update_animation_direction(player.global_position)
		move_and_slide()

func update_animation_direction(direction: Vector2) -> void:
	if not is_dying: # Only update direction if not dying
		if abs(direction.x) > abs(direction.y):
			if direction.x > 0:
				animation_orc.play("walk_side")
				animation_orc.flip_h = false # Not flipping the sprite for right movement
			else:
				animation_orc.play("walk_side")
				animation_orc.flip_h = true # Flip the sprite for left movement
		else:
			if direction.y > 0:
				animation_orc.play("walk_down")
			else:
				animation_orc.play("walk_up")
	
# Called when the orc takes damage
func take_damage(amount: int) -> void:
	if not is_dying:
		health -= amount
		print_debug("Orc took damage: ", amount, " Current health: ", health)

		if health > 0:
			flash_white()
		elif health <= 0:
			die()
# Make the sprite glow white for a short duration
func flash_white() -> void:
	animation_orc.modulate = Color(Color.RED) # Set the modulate color to white
	hit_timer.start() # Start the timer to reset the color
	hit_timer.connect("timeout", Callable(self, "_reset_color")) # Connect the timer's timeout signal

# Reset the sprite color back to normal
func _reset_color() -> void:
	print_debug("resetting modulation")
	animation_orc.modulate = Color(1, 1, 1, 1) # Reset to default color (or any other color if needed)
# Handle enemy death and drop a coin
func die() -> void:
	is_dying = true
	print_debug("Orc died, playing death animation")
	$sound_death.play()
	# Stop movement and play the die animation
	velocity = Vector2() # Stop the orc from moving
	animation_orc.play("die")
	# Drop a coin after the death animation starts
	drop_coin()
	#

func drop_coin() -> void:
	var coin = coin_scene.instantiate() # Instantiate the coin
	coin.position = position # Set coin position to the enemy's current position
	get_parent().add_child(coin) # Add the coin to the scene tree


func _on_animated_sprite_2d_animation_finished() -> void:
	print_debug("Animation Finished")
	queue_free()
