@tool
class_name DialogDef extends Resource

@export var id: StringName
@export var speaker: String
@export var portrait: Texture2D
@export var lines: PackedStringArray = []  # ponytail: one speaker per dialog; per-line speakers if conversations need them
