class_name ClickableComponent extends Area3D
## Makes its entity (the parent) clickable through the 3D camera.
## Needs a CollisionShape3D child. GameCoordinator wires every node in the
## "clickable" group automatically.

signal clicked(entity: Node)
signal hovered(entity: Node, on: bool)

@export var panel_id: StringName  # UI panel to open on click; empty = none


func _init() -> void:
	add_to_group(&"clickable")  # in _init so it's grouped before node_added fires


func _ready() -> void:
	input_event.connect(_on_input_event)
	mouse_entered.connect(func(): hovered.emit(get_parent(), true))
	mouse_exited.connect(func(): hovered.emit(get_parent(), false))


func _on_input_event(_camera: Node, event: InputEvent, _pos: Vector3, _normal: Vector3, _shape: int) -> void:
	var mb := event as InputEventMouseButton
	if mb and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(get_parent())
