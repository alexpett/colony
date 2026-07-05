extends Node2D
## Top-level coordinator for the main scene. Tracks the resource counter,
## registers every forager (existing or spawned later by the Queen), and
## mediates which single ant is player-controlled at a time.
##
## Click-to-possess: a left click within CLICK_RADIUS of a forager takes
## control of it (releasing whichever ant was previously controlled).
## Clicking the currently-controlled ant again, or pressing Escape,
## releases control back to autonomous behaviour.

const CLICK_RADIUS := 40.0

var food_collected: int = 0
var controlled_ant: Node = null

@onready var food_label: Label = $UI/FoodLabel
@onready var queen: Node = $Queen


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
	queen.on_food_delivered()


func _input(event: InputEvent) -> void:
	# Deliberately _input rather than _unhandled_input: the ants' pickable
	# CollisionObject2D shapes (CharacterBody2D + DetectionArea) consume the
	# click before it reaches the unhandled stage, so this needs to see the
	# event earlier in the dispatch order.
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_click(get_global_mouse_position())
	elif event.is_action_pressed("ui_cancel") and controlled_ant:
		controlled_ant.set_controlled(false)
		controlled_ant = null


func _handle_click(click_pos: Vector2) -> void:
	var target := _find_forager_near(click_pos)
	if target == null:
		return

	if controlled_ant == target:
		target.set_controlled(false)
		controlled_ant = null
		return

	if controlled_ant:
		controlled_ant.set_controlled(false)
	target.set_controlled(true)
	controlled_ant = target


func _find_forager_near(click_pos: Vector2) -> Node:
	var closest: Node = null
	var closest_dist := INF
	for forager in get_tree().get_nodes_in_group("foragers"):
		if not (forager is Node2D):
			continue
		var dist: float = click_pos.distance_to((forager as Node2D).global_position)
		if dist <= CLICK_RADIUS and dist < closest_dist:
			closest_dist = dist
			closest = forager
	return closest


func _update_label() -> void:
	food_label.text = "Food collected: %d" % food_collected
