@tool
class_name ShopItem extends MenuCard
## A square shop box for one def (food, egg...): icon, name and price.

@export var item: Resource:  ## any def with `name` and `cost`; `icon` is used if it has one
	set(v): item = v; _layout()


func _laid_out() -> void:
	super()
	if item:
		$Title.text = item.name
		$Price.text = "%d coin" % item.cost
		$Icon.texture = item.get(&"icon")
