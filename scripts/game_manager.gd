extends Node2D
## Top-level coordinator for the main scene. Tracks the resource counter and
## wires up any forager currently in the "foragers" group.
##
## v0.2 note: when the Queen starts spawning new Forager instances at
## runtime, have that spawn code call register_forager(new_ant) right after
## instancing it. Nothing else here needs to change to support many ants.

var food_collected: int = 0

@onready var food_label: Label = $UI/FoodLabel


func _ready() -> void:
	for forager in get_tree().get_nodes_in_group("foragers"):
		register_forager(forager)
	_update_label()


func register_forager(forager: Node) -> void:
	if forager.has_signal("food_delivered"):
		forager.food_delivered.connect(_on_food_delivered)


func _on_food_delivered() -> void:
	food_collected += 1
	_update_label()


func _update_label() -> void:
	food_label.text = "Food collected: %d" % food_collected
