extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func _on_close_btn_pressed() -> void:
	get_tree().quit()


func _on_replay_btn_pressed() -> void:
	print("You wanted to play again")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_play_btn_pressed() -> void:
	print("You wanted to play again")
	Global.difficulty = "easy"
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_play_hard_btn_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().change_scene_to_file("res://scenes/game.tscn")
