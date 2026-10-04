extends Node
## Routes clicks: world entity -> selection + its panel; panel choice -> TaskQueue.
## Any node in the "clickable" group with a `clicked(entity)` signal and a
## `panel_id` property gets wired automatically, including ones spawned later.

@onready var _ui := get_tree().get_first_node_in_group(&"ui_manager")
@onready var _queue := get_tree().get_first_node_in_group(&"task_queue")


func _ready() -> void:
	for node in get_tree().get_nodes_in_group(&"clickable"):
		_wire(node)
	get_tree().node_added.connect(_on_node_added)


## Panels call this with the task the player picked.
func submit(task: Task) -> bool:
	return _queue.add(task)


func _on_node_added(n: Node) -> void:
	if n.is_in_group(&"clickable"):
		_wire(n)


func _wire(clickable: Node) -> void:
	if not clickable.clicked.is_connected(_on_clicked):
		clickable.clicked.connect(_on_clicked.bind(clickable))


func _on_clicked(entity: Node, clickable: Node) -> void:
	if _ui.is_blocking():
		return
	EventBus.entity_selected.emit(entity)
	var panel_id = clickable.get(&"panel_id")
	if panel_id != null and not String(panel_id).is_empty():
		_ui.open(panel_id, entity)
	else:
		_send_avatar_to(entity)


# ponytail: direct walk-to-click until TaskWorkerComponent exists (build step 2), then clicks become tasks
func _send_avatar_to(entity: Node) -> void:
	var avatar := get_tree().get_first_node_in_group(&"avatar")
	var spot := Components.get_one(entity, InteractPointComponent) as Node3D
	if avatar == null or spot == null:
		return
	var mover := Components.get_one(avatar, MoverComponent) as MoverComponent
	if mover:
		mover.move_to(spot.global_position)
