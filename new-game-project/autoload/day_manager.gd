extends Node
## The in-day clock and the overnight pipeline.
## The clock only runs while at least one task is being worked on.

const DAY_START := 8 * 60       # 08:00, in minutes
const MINUTES_PER_SECOND := 10.0  # ponytail: placeholder pace

## Overnight phases, run in this order. Each is [group, method].
const NIGHT_PHASES := [
	[&"growth", &"apply_night"],         # pen push, idle-day effects, malleable countdown
	[&"growth", &"stabilize_if_ready"],  # lock in Hearthlings at zero days
	[&"growth", &"reset_daily"],         # one food + one action again
]

var minutes := float(DAY_START)
var _running_tasks := 0
var _report := {}


func _ready() -> void:
	EventBus.task_started.connect(func(_t, _w): _running_tasks += 1)
	EventBus.task_completed.connect(func(_t, _w): _running_tasks = maxi(_running_tasks - 1, 0))
	EventBus.sleep_requested.connect(sleep)
	EventBus.hearthling_stabilized.connect(_on_stabilized)


func _process(delta: float) -> void:
	if _running_tasks == 0:
		return
	var before := int(minutes)
	minutes += delta * MINUTES_PER_SECOND
	if int(minutes) != before:
		EventBus.clock_changed.emit(int(minutes))


func sleep() -> void:
	_report = {"day": GameState.day, "stabilized": []}
	EventBus.day_ending.emit(GameState.day)  # TaskQueue finishes tasks, UI closes panels
	_running_tasks = 0

	for phase in NIGHT_PHASES:
		get_tree().call_group(phase[0], phase[1])

	GameState.day += 1
	minutes = DAY_START
	EventBus.clock_changed.emit(int(minutes))
	EventBus.day_started.emit(GameState.day)  # CustomerManager brings due customers back
	EventBus.overnight_report_ready.emit(_report)
	_report = {}


func _on_stabilized(h: Resource) -> void:
	if not _report.is_empty():  # only collect during sleep()
		_report.stabilized.append(h)
