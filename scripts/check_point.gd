extends Area3D

signal reached  # Signal that the checkpoint was reached

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect the "reached" signal to the player's "_on_checkpoint_reached" method
	var player = get_parent().get_node("Player")  # Ensure you use the correct path to the Player node
	connect("reached", Callable(player, "_on_checkpoint_reached"))  # Connect signal to the player's method

func _on_body_entered(body: Node3D) -> void:
	#if body.is_in_group("Player"):  # Ensure that the object entering is the player
	emit_signal("reached")  # Emit the signal when the player enters the checkpoint area
