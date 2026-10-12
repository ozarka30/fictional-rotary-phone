extends Node
## Shared run state. Systems read and change it; the HUD listens via EventBus.

var day := 1
var coin := 30  # ponytail: enough for the hunter's Scent Trail machine and 3 fish
var materials := {&"brine_dough": 2, &"plain_dough": 2}  # dough, mix-in and food id -> count
var molds := {&"pup": -1}      # mold id -> uses left, -1 = unlimited
var hearthlings := {}          # uid -> HearthlingData
var active_requests: Array = []  # ActiveRequest
var waiting: Array = [preload("res://data/requests/hunter_tracker.tres")]  # new customers at the desk, in order
var heartseeds: Array = []     # Heartseed not in a body, ready to bake
var tutorial_flags := {}       # StringName -> bool
var yard := {}                 # environment id -> Array of slots: {"uid": Hearthling uid or -1, "machine": activity id or &"", "activity": activity id or &""}

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


## The Training Yard slots of `env`, created empty the first time.
func slots(env: EnvDef) -> Array:
	if not yard.has(env.id):
		yard[env.id] = range(env.slots).map(func(_i): return {"uid": -1, "machine": &"", "activity": &""})
	return yard[env.id]


## The slot a Hearthling is training in, or an empty Dictionary.
func slot_of(uid: int) -> Dictionary:
	for env_slots in yard.values():
		for s in env_slots:
			if s.uid == uid:
				return s
	return {}


## Takes a Hearthling out of the yard and out of the shop (delivered or remolded).
func remove_hearthling(uid: int) -> void:
	var s := slot_of(uid)
	if s:
		s.uid = -1
	hearthlings.erase(uid)


func new_uid() -> int:
	_next_uid += 1
	return _next_uid - 1


func _emit_mana() -> void:
	EventBus.mana_changed.emit(free_mana(), mana_capacity)
