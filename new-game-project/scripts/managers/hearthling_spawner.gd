extends Node
## Turns HearthlingData into a Hearthling entity, slots it, and registers it.
## Hatching (egg -> data) is a rule; this only builds the scene side.

@export var hearthling_scene: PackedScene  # res://entities/hearthling.tscn once it exists



## `slot` is any entity with a HearthlingSlot component (`put(entity)`).
func spawn(data: Resource, slot: Node) -> Node:
	var h := hearthling_scene.instantiate()
	var state := Components.with_method(h, &"set_data")
	if state:
		state.set_data(data)
	var slot_comp := Components.with_method(slot, &"put")
	if slot_comp:
		slot_comp.put(h)
	else:
		slot.add_child(h)
	GameState.hearthlings[data.uid] = data
	EventBus.hearthling_hatched.emit(data)
	return h
