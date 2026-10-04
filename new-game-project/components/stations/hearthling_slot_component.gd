class_name HearthlingSlotComponent extends Node
## Somewhere a Hearthling can live (a pen). The spawner calls `put`.


func put(h: Node3D) -> void:
	get_parent().add_child(h)
	h.position = Vector3(randf_range(-0.6, 0.6), 0, 0.4)  # ponytail: loose scatter, real spots when pens hold several
