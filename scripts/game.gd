extends Node3D

@onready var hud = $HUD  # Reference to the Label node in the CanvasLayer (HUD)
var game_timer = Timer.new()  # Create a new Timer instance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize global variables
	#$BackgroundMusic.play()
	Global.coins = 0
	Global.lives = 3
	Global.portal = -1
	#Global.timeLeft = 30
	
	# Add the Timer to the scene
	add_child(game_timer)
	showLives()
	
	# Connect the "timeout" signal to a function
	game_timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	
	Global.connect("playerDied", Callable(self, "_on_player_died"))
	
	# Start the timer with a specified duration
	game_timer.start(Global.timeLeft)
	
	# Set the initial text in the HUD Label
	hud.get_node("Time/TimeLabel").text = str(Global.timeLeft)
	
	if Global.difficulty == "easy":
		var bombs = get_node("Bombs").get_children()
		for b in bombs:
			b.set_collision_mask_value(1,false)

# Called when the timer finishes
func _on_timer_timeout():
	# This function is called when the timer finishes
	Global.lostALife()
	game_timer.start(Global.timeLeft/2)
# Call game over when out of lives

func showLives():
#	"♥️♥️🖤"
	var health=""
	var i = 0;
	var lives = floor(Global.lives)
	
	while i<lives:
		health+="♥️"
		i+=1
	
	while i<3:
		health+="🖤"
		i+=1
		
	hud.get_node("Health/HealthBar").text = health

func _on_player_died():
	# This function will be called when the player dies
	print("Player died!")
	showLives()  # Update the health bar or UI

	# Check if the player has no lives left
	if Global.lives < 1 :
		Global.gameWon=false
		game_over()  # Trigger game over


func game_over():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Global.gameWon:
		get_tree().change_scene_to_file("res://scenes/win.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/lose.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var left = game_timer.time_left
	var mins = floor(left / 60)
	var secs = left - (mins * 60)  # Calculate remaining seconds
	hud.get_node("Time/TimeLabel").text = "%02.0f:%02.0f" % [mins, secs]
	
	if Input.is_action_just_pressed("quit_game"):
		get_tree().quit()
	elif Input.is_action_just_pressed("restart_game"):
		get_tree().reload_current_scene()


func _on_portal_body_entered(body: Node3D) -> void:
	var portals = get_node("Portals").get_children()
	var pos = 0 if Global.portal >0 else -1
	var target : Vector3 = portals[pos].position
	
	Global.portal*=-1
	
	target.x+=1
	$simplePlayer.position  =target
