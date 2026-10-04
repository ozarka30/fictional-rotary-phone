class_name MoverComponent extends NavigationAgent3D
## Walks its entity (the parent Node3D) across the navmesh.
## If `sprite` is set, plays "run"/"idle" and flips it to face the walk direction.

signal arrived()

@export var speed := 3.0  # meters per second
@export var sprite: AnimatedSprite3D

var moving := false

@onready var _body: Node3D = get_parent()


func move_to(pos: Vector3) -> void:
	target_position = pos
	moving = true
	_play(&"run")


func _physics_process(delta: float) -> void:
	if not moving:
		return
	if is_navigation_finished():
		moving = false
		_play(&"idle")
		arrived.emit()
		return
	var next := get_next_path_position()
	var step := (next - _body.global_position)
	step.y = 0.0
	if sprite and absf(step.x) > 0.01:
		sprite.flip_h = step.x < 0.0  # Duelyst sprites face right
	_body.global_position = _body.global_position.move_toward(Vector3(next.x, _body.global_position.y, next.z), speed * delta)


func _play(anim: StringName) -> void:
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)
