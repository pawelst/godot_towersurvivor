extends Node2D

func _ready() -> void:
	pass
	
func spawn_orcs():
	const ORC = preload("res://scenes/orc.tscn")
	var new_orc = ORC.instantiate()
	new_orc.global_position = Vector2(-100,100)
	add_child(new_orc)
	


func _on_timer_timeout() -> void:
	spawn_orcs()
