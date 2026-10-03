extends Node
## Pending avatar work. Validates on the way in, hands out first-come first-served.

var _pending: Array[Task] = []


func _ready() -> void:
	EventBus.day_ending.connect(_finish_all)


## Returns false (and emits task_rejected) if the task can't run right now.
func add(task: Task) -> bool:
	var reason := task.reject_reason()
	if not reason.is_empty():
		EventBus.task_rejected.emit(task, reason)
		return false
	_pending.append(task)
	EventBus.task_queued.emit(task)
	return true


## Idle workers call this. Null when there's nothing to do.
func take() -> Task:
	return _pending.pop_front()  # ponytail: FIFO; per-worker or priority picking if clones need it


func cancel(task: Task) -> void:
	_pending.erase(task)


func has_pending() -> bool:
	return not _pending.is_empty()


## Sleeping finishes whatever is still waiting, instantly.
func _finish_all(_day: int) -> void:
	for task in _pending:
		task.run()
		EventBus.task_completed.emit(task, null)
	_pending.clear()
