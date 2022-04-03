extends Enemy


# ----------------------------------------------------------------------------
func process_ai(_delta: float) -> void:
	## look_at(goal, Vector3.UP)

	var lookat: float
	lookat = atan2(global_transform.origin.x - goal.x, global_transform.origin.z - goal.z)
	rotation.y = lerp_angle(rotation.y, lookat, rotation_speed * _delta)
