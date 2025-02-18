extends Area3D

@onready var debris = $Debris
@onready var smoke = $Smoke
@onready var fire = $Fire
@onready var explosion_sound = $ExplosionSound
signal respawn

func explode():
	debris.emitting = true
	smoke.emitting = true
	fire.emitting = true
	explosion_sound.play()
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _on_body_entered(body: Node3D) -> void:
	#Global.lostALife()
	explode()
	set_collision_layer_value(3,false)
	set_collision_mask_value(1,false)
	await get_tree().create_timer(0.5).timeout
	emit_signal("respawn")
