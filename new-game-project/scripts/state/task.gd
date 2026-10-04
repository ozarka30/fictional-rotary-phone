@tool
class_name Task extends Resource
## One unit of avatar work. The thing that builds the task (a TaskProvider)
## fills in what to check and what to do; workers just walk, wait, and apply.

enum Kind { FORM_AVATAR, HATCH, FEED, ACT, MOVE_PEN, TRAIN, GREET, DELIVER }

var kind: Kind
var target: Node          # entity the avatar walks to
var hearthling_uid := -1
var payload_id: StringName  # food, action, pen... id in Database
var duration := 1.0       # seconds of work at the target
var check: Callable       # () -> String; "" means OK, anything else is the reject reason
var apply: Callable       # () -> void; runs when the work finishes


func reject_reason() -> String:
	return check.call() if check.is_valid() else ""


func run() -> void:
	if apply.is_valid():
		apply.call()
