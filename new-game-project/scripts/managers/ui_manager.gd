extends Node
## One modal panel at a time; blocks world clicks while a panel or dialog is up.
## Panels are any nodes in the "panel" group, looked up by node name == panel_id.
## A panel may define open(entity) and close().

var _current: Node
var _dialog_open := false


func _ready() -> void:
	EventBus.dialog_requested.connect(func(_d): _dialog_open = true)
	EventBus.dialog_finished.connect(func(_id): _dialog_open = false)
	EventBus.day_ending.connect(func(_day): close())
	EventBus.task_rejected.connect(func(_t, reason): print("Can't do that: ", reason))  # ponytail: swap for HUD hint text


func is_blocking() -> bool:
	return _current != null or _dialog_open


func open(panel_id: StringName, entity: Node = null) -> void:
	close()
	for panel in get_tree().get_nodes_in_group(&"panel"):
		if panel.name == panel_id:
			_current = panel
			panel.show()
			if panel.has_method(&"open"):
				panel.open(entity)
			EventBus.panel_opened.emit(panel_id)
			return
	push_error("UIManager: no panel named '%s'" % panel_id)


func close() -> void:
	if _current == null:
		return
	var panel_id := StringName(_current.name)
	if _current.has_method(&"close"):
		_current.close()
	_current.hide()
	_current = null
	EventBus.panel_closed.emit(panel_id)
