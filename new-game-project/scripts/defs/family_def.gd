@tool
class_name FamilyDef extends Resource
## One base creature. Its form is picked by its strongest affinity at stabilization.

@export var id: StringName
@export var name: String
@export var base_sprite: Texture2D
@export var base_potential := 40.0  # every stat's starting cap
@export var base_stat := 10.0       # every stat's starting value
@export var form_names: Dictionary[Types.Affinity, String] = {}
@export var form_sprites: Dictionary[Types.Affinity, Texture2D] = {}
# ponytail: form = top affinity; hidden forms (conditions, idle days) get a FormDef when they exist
