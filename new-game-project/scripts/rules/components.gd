class_name Components
## Sibling lookup for component-based entities. No deep node paths.


static func get_one(entity: Node, type: Variant) -> Node:
	for child in entity.get_children():
		if is_instance_of(child, type):
			return child
	return null


## Duck-typed lookup: first child that has `method`. Handy before a component's class exists.
static func with_method(entity: Node, method: StringName) -> Node:
	for child in entity.get_children():
		if child.has_method(method):
			return child
	return null
