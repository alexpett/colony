extends CharacterBody2D
## Forager ant. v0.2: autonomous by default (seeks the nearest food node,
## then the colony to deliver, else wanders); GameManager flips
## is_controlled via set_controlled() to hand it keyboard input instead.
## Multiple Foragers can exist and act independently — click-to-possess and
## spawn coordination live in GameManager/Queen, not here.

signal food_delivered

const SPEED := 220.0
const WANDER_ARRIVAL_DIST := 8.0
const TARGET_ARRIVAL_DIST := 4.0

# Half the ant's visual/collision size. Used to keep the whole sprite (not
# just its center) inside the map bounds. This is a fixed-map stopgap for
# v0.1 — a real solution for scrolling/larger terrain is a separate task.
const HALF_SIZE := 16.0

var has_food: bool = false
var is_controlled: bool = false

var _wander_target: Vector2
var _has_wander_target: bool = false

@onready var visual: ColorRect = $Visual
@onready var selection_ring: ColorRect = $SelectionRing


func _ready() -> void:
	# Membership in this group lets GameManager find and register every
	# forager currently in the scene, including ones spawned later (v0.2 Queen).
	add_to_group("foragers")
	_update_visual()


func _physics_process(_delta: float) -> void:
	if is_controlled:
		velocity = _get_input_direction() * SPEED
	else:
		velocity = _get_autonomous_direction() * SPEED
	move_and_slide()
	_clamp_to_map_bounds()


func set_controlled(value: bool) -> void:
	is_controlled = value
	_update_visual()


func _get_input_direction() -> Vector2:
	var input_dir := Vector2.ZERO

	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		input_dir.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		input_dir.x += 1.0
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		input_dir.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		input_dir.y += 1.0

	if input_dir.length() > 0.0:
		input_dir = input_dir.normalized()

	return input_dir


func _get_autonomous_direction() -> Vector2:
	var target := _get_autonomous_target()
	var to_target := target - global_position
	if to_target.length() < TARGET_ARRIVAL_DIST:
		return Vector2.ZERO
	return to_target.normalized()


func _get_autonomous_target() -> Vector2:
	if has_food:
		var colony := get_tree().get_first_node_in_group("colony")
		if colony is Node2D:
			return (colony as Node2D).global_position
	else:
		var nearest_food := _find_nearest_food()
		if nearest_food:
			return nearest_food.global_position

	return _get_wander_target()


func _find_nearest_food() -> Node2D:
	var nearest: Node2D = null
	var nearest_dist := INF
	for food in get_tree().get_nodes_in_group("food"):
		if not (food is Node2D):
			continue
		var food_node := food as Node2D
		var dist := global_position.distance_squared_to(food_node.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = food_node
	return nearest


func _get_wander_target() -> Vector2:
	if not _has_wander_target or global_position.distance_to(_wander_target) < WANDER_ARRIVAL_DIST:
		var map_size := get_viewport_rect().size
		_wander_target = Vector2(
			randf_range(HALF_SIZE, map_size.x - HALF_SIZE),
			randf_range(HALF_SIZE, map_size.y - HALF_SIZE)
		)
		_has_wander_target = true
	return _wander_target


func _clamp_to_map_bounds() -> void:
	var map_size := get_viewport_rect().size
	position.x = clamp(position.x, HALF_SIZE, map_size.x - HALF_SIZE)
	position.y = clamp(position.y, HALF_SIZE, map_size.y - HALF_SIZE)


func _on_detection_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("food") and not has_food:
		if area.has_method("collect"):
			area.collect()
		has_food = true
		_update_visual()
	elif area.is_in_group("colony") and has_food:
		has_food = false
		_update_visual()
		food_delivered.emit()


func _update_visual() -> void:
	if visual == null:
		return
	# Green while carrying food, orange while empty-handed.
	visual.color = Color(0.2, 0.8, 0.2, 1.0) if has_food else Color(0.9, 0.5, 0.1, 1.0)
	if selection_ring != null:
		selection_ring.visible = is_controlled
