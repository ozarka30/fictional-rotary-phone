class_name TaskWorkerComponent extends Node
## Takes tasks from the TaskQueue: walks to the target's InteractPoint, works
## for the task's duration, applies it. One task at a time.

@onready var _mover := Components.get_one(get_parent(), MoverComponent) as MoverComponent
@onready var _queue := get_tree().get_first_node_in_group(&"task_queue")

var _task: Task
var _working := false


func _ready() -> void:
	EventBus.task_queued.connect(func(_t): _try_next())
	EventBus.day_ending.connect(func(_d): _finish_now())
	_mover.arrived.connect(_on_arrived)


func is_idle() -> bool:
	return _task == null


func _try_next() -> void:
	if not is_idle() or _queue == null:
		return
	_task = _queue.take()
	if _task == null:
		return
	var spot := Components.get_one(_task.target, InteractPointComponent) as Node3D
	_mover.move_to(spot.global_position if spot else _task.target.global_position)


func _on_arrived() -> void:
	if _task == null or _working:
		return
	_working = true
	var task := _task
	EventBus.task_started.emit(task, get_parent())
	await get_tree().create_timer(task.duration).timeout
	if _task == task:  # not already finished by sleep
		_complete()


func _complete() -> void:
	var task := _task
	_task = null
	_working = false
	task.run()
	EventBus.task_completed.emit(task, get_parent())
	_try_next()


## Sleeping finishes the current task instantly, wherever the avatar is.
func _finish_now() -> void:
	if _task:
		_complete()
