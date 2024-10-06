extends Area2D

func _ready():
	connect("body_entered", self._on_body_entered)

# When the player steps on the bow
func _on_body_entered(body):
	if body.name == "Player":
		body.pick_up_bow() # Call the player's method to equip the bow
		queue_free() # Remove the bow from the scene after pickup