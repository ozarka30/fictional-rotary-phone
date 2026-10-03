extends Node
## The walkthrough as data: each beat shows a hint, unlocks a station,
## and waits for one EventBus signal before moving on.

const FIRST_REQUEST := &"hunter_tracker"

const BEATS := [
	{"hint": "The shop awakens.",                         "unlock": &"",               "wait": &"customer_arrived"},
	{"hint": "A customer! Listen to what they need.",     "unlock": &"",               "wait": &"dialog_finished"},
	{"hint": "The shop can't speak. Form an avatar.",     "unlock": &"gem",            "wait": &"avatar_formed"},
	{"hint": "Greet the hunter at the front desk.",       "unlock": &"front_desk",     "wait": &"request_received"},
	{"hint": "Take the egg.",                             "unlock": &"",               "wait": &"egg_received"},
	{"hint": "Build an incubator and hatch the egg.",     "unlock": &"incubator",      "wait": &"hearthling_hatched"},
	{"hint": "Give it one food and one action each day.", "unlock": &"pen",            "wait": &"hearthling_changed"},
	{"hint": "Sleep to move the days along.",             "unlock": &"",               "wait": &"hearthling_stabilized"},
	{"hint": "It has settled! Train it toward the goal.", "unlock": &"training_gadget", "wait": &"customer_arrived"},
	{"hint": "The hunter is back. Hand it over.",         "unlock": &"",               "wait": &"request_completed"},
	{"hint": "Tutorial done.",                            "unlock": &"",               "wait": &""},
]

var beat := -1


func _ready() -> void:
	var waited := {}
	for b in BEATS:
		var sig: StringName = b.wait
		if sig.is_empty() or waited.has(sig):
			continue
		waited[sig] = true
		EventBus.connect(sig, _on_event.bind(sig).unbind(_arg_count(sig)))
	_advance.call_deferred()  # let the other managers finish _ready
	_start.call_deferred()


func _start() -> void:
	var req := Database.get_def(&"requests", FIRST_REQUEST)
	var customers := get_tree().get_first_node_in_group(&"customer_manager")
	if req and customers and customers.customer_scene:
		customers.arrive(req)


func _on_event(sig: StringName) -> void:
	if beat in range(BEATS.size()) and BEATS[beat].wait == sig:
		_advance()


func _advance() -> void:
	beat += 1
	if beat >= BEATS.size():
		return
	var station: StringName = BEATS[beat].unlock
	if not station.is_empty() and not GameState.unlocked_stations.has(station):
		GameState.unlocked_stations.append(station)
		EventBus.station_unlocked.emit(station)
	EventBus.tutorial_beat_changed.emit(beat)


func hint() -> String:
	return BEATS[beat].hint if beat in range(BEATS.size()) else ""


func _arg_count(sig: StringName) -> int:
	for s in EventBus.get_signal_list():
		if s.name == sig:
			return s.args.size()
	return 0
