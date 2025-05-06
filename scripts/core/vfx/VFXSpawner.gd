extends Node2D

@onready var spawn_position : Marker2D = $SpawnPosition
@export var vfx : PackedScene
@export var animation_name : String = "default"
@export var flip_effect_animation_graphic := false

var flipped := false

func flip_spawn_position(flip : bool):
	if flip and not flipped:
		flipped = true 
		spawn_position.position.x *= -1
	pass

func set_spawn_position_to(new_position : Vector2):
	spawn_position.position = to_local(new_position)
	pass


func spawn_animated_effect():
	var effect = vfx.instantiate()
	get_tree().root.add_child(effect)
	effect.global_position = spawn_position.global_position
	
	var sprite: AnimatedSprite2D = effect.get_node("AnimatedSprite2D")
	if flipped and flip_effect_animation_graphic:
		sprite.flip_h = true
	sprite.play(animation_name)
	# deletes effect when animated sprite finished the animation
	sprite.animation_finished.connect(func():effect.queue_free())
	pass
