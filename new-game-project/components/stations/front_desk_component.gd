class_name FrontDeskComponent extends Node
## The avatar's GREET task here opens the customer scene for whoever waits at the desk.

var _waiting: Node


func _ready() -> void:
	EventBus.customer_arrived.connect(func(c): _waiting = c)
	EventBus.customer_left.connect(func(c): if c == _waiting: _waiting = null)


func configure_task(t: Task) -> void:
	t.check = func() -> String:
		return "" if is_instance_valid(_waiting) else "No one is waiting at the desk"
	t.apply = func():
		if is_instance_valid(_waiting):
			get_tree().get_first_node_in_group(&"ui_manager").open(&"CustomerScene", _waiting)
