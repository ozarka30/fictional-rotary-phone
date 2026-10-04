extends Node
## Walks customers in to the desk on arrival and return days, and back out.

@export var customer_scene: PackedScene
@export var entrance_path := NodePath("../World/Entrance")
@export var desk_path := NodePath("../World/CustomerSpot")
@export var customers_root_path := NodePath("../World/Customers")

@onready var entrance: Node3D = get_node(entrance_path)
@onready var desk: Node3D = get_node(desk_path)
@onready var customers_root: Node3D = get_node(customers_root_path)

var _returns := {}  # day -> Array[Resource] (requests coming back that day)


func _ready() -> void:
	EventBus.day_started.connect(_on_day_started)


## A customer with `request` walks in. Returning customers come through here too.
func arrive(request: Resource) -> Node:
	var c := customer_scene.instantiate()
	customers_root.add_child(c)
	c.global_position = entrance.global_position
	var giver := Components.with_method(c, &"set_request")
	if giver:
		giver.set_request(request)
	_walk(c, desk.global_position, func(): EventBus.customer_arrived.emit(c))
	return c


## Bring this request's customer back on `day`.
func schedule_return(request: Resource, day: int) -> void:
	_returns.get_or_add(day, []).append(request)


func leave(c: Node) -> void:
	_walk(c, entrance.global_position, func():
		EventBus.customer_left.emit(c)
		c.queue_free())


func _on_day_started(day: int) -> void:
	for request in _returns.get(day, []):
		arrive(request)
	_returns.erase(day)


func _walk(c: Node, to: Vector3, then: Callable) -> void:
	var mover := Components.with_method(c, &"move_to")
	if mover == null:  # no mover yet: teleport
		c.global_position = to
		then.call()
		return
	mover.arrived.connect(then, CONNECT_ONE_SHOT)
	mover.move_to(to)
