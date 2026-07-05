extends Area2D
## Fixed nest position. Delivery logic lives on the ant (it knows whether it's
## carrying food); this node just needs to exist and be identifiable.


func _ready() -> void:
	add_to_group("colony")
