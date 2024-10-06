extends Node2D

var speed = 300
var target = null

func _process(delta: float) -> void:
	if target and is_instance_valid(target):  # Check if the target is still valid
		# Calculate the direction to the target
		var direction = (target.position - position).normalized()
		
		# Move the arrow towards the target
		position += direction * speed * delta
		
		# Rotate the arrow to point towards the target
		rotation = direction.angle()
		
		# Check if the arrow is close enough to the target to hit it
		if position.distance_to(target.position) < 10:
			target.take_damage(10) # Assuming enemy has a take_damage method
			queue_free() # Destroy the arrow after hitting
	else:
		# If the target is no longer valid, free the arrow
		queue_free() # Destroy the arrow if the target no longer exists
