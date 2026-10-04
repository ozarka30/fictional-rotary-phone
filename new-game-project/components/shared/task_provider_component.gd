class_name TaskProviderComponent extends Node
## Builds the task an avatar performs when its entity is clicked.
## Later, panels pick a specific task (which food, which action); for now each
## station offers one default task.

@export var kind := Task.Kind.ACT
@export var duration := 1.5  # seconds of work once the avatar arrives


func make_task() -> Task:
	var t := Task.new()
	t.kind = kind
	t.target = get_parent()
	t.duration = duration
	var config := Components.with_method(get_parent(), &"configure_task")
	if config:
		config.configure_task(t)  # the station fills in check/apply
	return t
