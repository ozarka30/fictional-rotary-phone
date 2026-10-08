extends Control
## Shows the comic UI pieces with real data. Run this scene (F6) to check them.


func _ready() -> void:
	var egg: EggDef = load("res://data/eggs/basic_egg.tres")
	var pup := Hatching.hatch(egg, load("res://data/families/pup.tres"), 1)
	Shaping.feed(pup, load("res://data/foods/brine_fish.tres"), load("res://data/pens/basic_pen.tres"))
	Training.train(pup, Training.YARDS[1].stats)
	%EggCard.show_egg(egg, load("res://addons/duelyst_animated_sprites/spriteframes/units/f5_egg.tres"))
	%PupCard.show_hearthling(pup, load("res://addons/duelyst_animated_sprites/spriteframes/units/neutral_xho.tres"))
	await get_tree().process_frame  # let the cards lay out first
	%Callout.say("A basic egg. Hatch it at the incubator!", %EggCard.global_position + Vector2(%EggCard.size.x * 0.8, 60))
	%Thought.say("Something salty... it might like the water.", %PupCard.global_position + Vector2(%PupCard.size.x - 40, 40))
