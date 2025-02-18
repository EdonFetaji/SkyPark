extends Area3D
@export var hud : CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_y(deg_to_rad(2))
	
func _on_body_entered(body: Node3D) -> void:
	Global.coins +=1
	hud.get_node("Coins/CoinsLabel").text = str(Global.coins)
	if Global.coins >= Global.NUM_COINS_WIN:
		Global.gameWon=true
		var game_scene = get_tree().root.get_node("Game")
		game_scene.game_over()
	set_collision_layer_value(4,false)
	set_collision_mask_value(1,false)
	
	$AnimationPlayer.play("bounce")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
	print("Coin is Collected")
