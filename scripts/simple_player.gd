extends CharacterBody3D

const SPEED = 4.50
const JUMP_VELOCITY = 8
const GRAVITY = 24
const MOUSE_SENSITIVITY = 0.002  # Adjust this for smooth rotation
var last_checkpoint_position = Vector3.ZERO
var platform_velocity = Vector3.ZERO
var current_platform = null
var last_platform_position = Vector3.ZERO

@onready var camera_controller = $Camera_Controller  # Reference to Camera Controller

func _ready():
	# Access the Game scene directly by getting the root node and its children
	var game_scene = get_tree().root.get_node("Game")  # "Game" should be the name of the Game scene
	if game_scene:
		var checkpoints = game_scene.get_node("checkpoints")  # Get the checkpoints node inside the Game scene
		if checkpoints:
			print("connecting checkpoints!")
			# Loop through all checkpoints and connect their "reached" signal to the player
			for checkpoint in checkpoints.get_children():  # Get all checkpoint nodes
				if checkpoint is Area3D:  # Ensure the node is an Area3D (checkpoints are usually Area3D)
					checkpoint.connect("reached", Callable(self, "_on_checkpoint_reached"))
		else:
			print("Error: Checkpoints node not found!")
	else:
		print("Error: Game scene not found!")

	# Capture the mouse so it doesn't leave the window
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	# Rotate camera with mouse movement
	if event is InputEventMouseMotion:
		camera_controller.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)  # Rotate left/right
		# Make the player rotate with the camera
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)  # Rotate player to match camera
		# Wrap the mouse cursor when it reaches the screen edges
		_wrap_mouse_cursor()

func _wrap_mouse_cursor():
	# Get the viewport size
	var viewport_size = get_viewport().get_visible_rect().size
	# Get the current mouse position
	var mouse_pos = get_viewport().get_mouse_position()

	# Check if the mouse is outside the viewport bounds
	if mouse_pos.x <= 0 or mouse_pos.x >= viewport_size.x or mouse_pos.y <= 0 or mouse_pos.y >= viewport_size.y:
		# Wrap the mouse position to the opposite side
		var new_mouse_pos = Vector2(
			fposmod(mouse_pos.x, viewport_size.x),  # Wrap X
			fposmod(mouse_pos.y, viewport_size.y)   # Wrap Y
		)
		# Set the new mouse position
		get_viewport().warp_mouse(new_mouse_pos)

func _physics_process(delta: float) -> void:
	# Apply gravity correctly
	if not is_on_floor():
		velocity.y -= GRAVITY * delta  

	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get movement input
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# Make movement relative to camera rotation
	var direction = camera_controller.global_transform.basis * Vector3(-input_dir.x, 0, -input_dir.y)
	direction.y = 0  # Prevent unwanted vertical movement
	direction = direction.normalized()

	if direction.length() > 0:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Detect if player is on a moving platform
	platform_velocity = Vector3.ZERO
	if is_on_floor():
		var collision = get_last_slide_collision()
		if collision:
			var platform = collision.get_collider()
			if platform and platform.is_in_group("MovingPlatforms"):
				# Track the platform and calculate its velocity
				if current_platform == platform:
					platform_velocity = (platform.global_transform.origin - last_platform_position) / delta
				current_platform = platform
				last_platform_position = platform.global_transform.origin
			else:
				current_platform = null  # Reset if not standing on platform

	# Apply movement with platform velocity
	velocity += platform_velocity
	move_and_slide()

	# Smooth camera follow
	camera_controller.position = lerp(camera_controller.position, position, 0.15)

# Method to update last checkpoint position
func _on_checkpoint_reached():
	print("Checkpoint reached!")
	last_checkpoint_position = position  # Save position when checkpoint is reached

# Respawn the player at the last checkpoint
func respawn_at_last_checkpoint():
	if Global.lives >= 1:
		Global.lostALife()  # Decrease lives
		position = last_checkpoint_position  # Respawn at the last checkpoint
		position.y += 1  # Ensure player doesn't spawn inside the ground

func _on_fall_zone_body_entered(body: Node3D) -> void:
	print("Caught the sucker trying to escape!")
	respawn_at_last_checkpoint()


func _on_bomb_respawn() -> void:
	respawn_at_last_checkpoint()
