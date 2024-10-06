extends CharacterBody2D

const speed = 100
var has_bow = false
var current_direction = "none"
var shooting_timer: Timer

var money = 0 # Player's money counter
var money_label
var hud_node

var click_position = Vector2()
var target_position = Vector2()

# References to the animation player and the animations
@onready var animation_player = $AnimatedSprite2D
@onready var label = $Label
@onready var idle_timer = $Timer
@onready var range_detector = $RangeDetector # A node to detect enemies in range

func _ready():
	click_position = position
	target_position = position
	$CollectionRange.connect("body_entered", Callable(self, "_on_CollectionRange_body_entered"))

	call_deferred("_initialize_money_label")
	shooting_timer = Timer.new()
	shooting_timer.wait_time = 0.5# Set time between shots
	shooting_timer.connect("timeout", self._shoot_arrow)
	add_child(shooting_timer)
	
func _initialize_money_label():
	hud_node = get_parent().get_node("HUD") # Get the HUD node
	money_label = hud_node.get_node("MoneyLabel") 
	money_label.text = "Money: $" + str(money) # Initialize the money display
			
func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("left_click"):
		print_debug("New move target!")
		click_position = get_global_mouse_position()
		
	if position.distance_to(click_position) > 3:
		target_position = (click_position - position).normalized()
		velocity = target_position * speed
		# Check the movement direction
		update_animation_direction(target_position)
		move_and_slide()
	else:
		# If close enough to the target, stop movement and play idle animation
		velocity = Vector2() # Stop movement
		animation_player.play("idle")
		
func update_animation_direction(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			animation_player.play("walk_side")
			animation_player.flip_h = false # Not flipping the sprite for right movement
		else:
			animation_player.play("walk_side")
			animation_player.flip_h = true # Flip the sprite for left movement
	else:
		if direction.y > 0:
			animation_player.play("walk_down")
		else:
			animation_player.play("walk_up")

# Method to pick up the bow
func pick_up_bow() -> void:
	has_bow = true
	print_debug("Bow picked up!")
	$sound_pickup.play()
	shooting_timer.start() # Start shooting automatically when the bow is picked up

# Automatically shoot arrows at enemies in range
func _shoot_arrow() -> void:
	if has_bow:
		var enemies = range_detector.get_overlapping_bodies()
		for enemy in enemies:
			print_debug("I see something ... ",str(enemy))
			if enemy.is_in_group("enemies"):
				shoot_arrow_at(enemy)
				break

# Function to shoot an arrow
func shoot_arrow_at(enemy: Node) -> void:
	print_debug("Shooting!")
	animation_player.play("shooting")
	var arrow = preload("res://scenes/arrow.tscn")
	var new_arrow = arrow.instantiate() # Instantiate an arrow (create an arrow scene)
	new_arrow.position = position # Set arrow's starting position
	new_arrow.target = enemy # Set the target
	get_parent().add_child(new_arrow)
	$sound_shoot.play()
# Function called when the player picks up a coin
func pick_up_coin() -> void:
	money += 1 # Increase money by 1 (or another amount based on game design)
	$sound_coin.play()
	update_money_display() # Update the money display

# Update the money display on the UI
func update_money_display() -> void:
	money_label.text = "Money: $" + str(money)
