extends StaticBody
class_name Vegetable


# ----------------------------------------------------------------------------
signal vegetable_eaten


# ----------------------------------------------------------------------------
var health: int


# ----------------------------------------------------------------------------
func _ready() -> void:
	health = 4
	rotation_degrees.y = rand_range(0.0, 180.0)


# ----------------------------------------------------------------------------
func one_bite() -> void:
	if health < 0:
		return

	health -= 1

	# leafs
	if health == 3:
		$Model/Leaf1.visible = false
	elif health == 2:
		$Model/Leaf2.visible = false
	else:
		$Model/Leaf3.visible = false

	# this veggie is no more
	if health == 0:
		emit_signal("vegetable_eaten")
		queue_free()
