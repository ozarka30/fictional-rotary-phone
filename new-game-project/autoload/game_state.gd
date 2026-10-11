extends Node
## Shared run state. Systems read and change it; the HUD listens via EventBus.

var day := 1
var coin := 20
var materials := {&"brine_dough": 2, &"plain_dough": 2}  # dough, mix-in and food id -> count
var molds := {&"pup": -1}      # mold id -> uses left, -1 = unlimited
var hearthlings := {}          # uid -> HearthlingData
var active_requests: Array = []  # ActiveRequest
var waiting: Array = [preload("res://data/requests/hunter_tracker.tres")]  # new customers at the desk, in order
var heartseeds: Array = []     # Heartseed not in a body, ready to bake
var tutorial_flags := {}       # StringName -> bool
var env_activities := {}       # Training Yard environment id -> Array of installed activity ids (&"" = empty slot)

var mana_capacity := 10        # ponytail: placeholder, tune with the tutorial costs
var _mana_locks := {}          # owner_id -> amount
var _next_uid := 1


func free_mana() -> int:
	var used := 0
	for amount in _mana_locks.values():
		used += amount
	return mana_capacity - used


## Locks mana for as long as the owner runs. False if there isn't enough free.
func lock_mana(owner_id: StringName, amount: int) -> bool:
	if _mana_locks.has(owner_id):
		return true
	if amount > free_mana():
		return false
	_mana_locks[owner_id] = amount
	_emit_mana()
	return true


func unlock_mana(owner_id: StringName) -> void:
	if _mana_locks.erase(owner_id):
		_emit_mana()


func add_coin(amount: int) -> void:
	coin += amount
	EventBus.coin_changed.emit(coin)


func add_material(material_id: StringName, amount: int) -> void:
	materials[material_id] = materials.get(material_id, 0) + amount
	EventBus.materials_changed.emit(material_id, materials[material_id])


func new_uid() -> int:
	_next_uid += 1
	return _next_uid - 1


func _emit_mana() -> void:
	EventBus.mana_changed.emit(free_mana(), mana_capacity)
