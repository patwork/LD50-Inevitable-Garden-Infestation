extends Enemy


# ----------------------------------------------------------------------------
var node_timer: Timer
var chosen_vegetable: Vegetable


# ----------------------------------------------------------------------------
func _ready() -> void:
	move_speed = 3.0
	move_accel = 4.0
	move_deaccel = 6.0
	proximity_len_squared = 2.0
	health = 30

	node_timer = $Timer as Timer
	chosen_vegetable = null


# ----------------------------------------------------------------------------
func process_ai(_delta: float) -> void:
	# look at target
	var lookat: float
	lookat = atan2(global_transform.origin.x - goal.x, global_transform.origin.z - goal.z)
	rotation.y = lerp_angle(rotation.y, lookat, rotation_speed * _delta)

	# distance to target
	var distance_squared: float = (goal - global_transform.origin).length_squared()

	# newborn rabbit
	if state_current == States.STATE_SPAWN:
		if is_on_floor():
			state_current = States.STATE_WANDER

	# wander around
	elif state_current == States.STATE_WANDER:
			state_current = get_veggie_goal()

	# approaching veggie
	elif state_current == States.STATE_FOLLOW:
		if distance_squared < proximity_len_squared:
			state_current = States.STATE_EAT
			node_timer.start()

	# eating veggie
	elif state_current == States.STATE_EAT:
		if chosen_vegetable and not is_instance_valid(chosen_vegetable):
			chosen_vegetable = null
			state_current = States.STATE_WANDER

	# escaping
	elif state_current == States.STATE_ESCAPE:
		if distance_squared < proximity_len_squared:
			state_current = States.STATE_WANDER



# ----------------------------------------------------------------------------
func _on_Area_area_entered(area: Area) -> void:
	if is_dead:
		return

	# check owner
	var owner := area.get_owner()

	# hit by player
	if owner.get_name() == "Player":
		health -= 10
		if health > 0:
			hit_rabbit(owner)
		else:
			rip_rabbit()


# ----------------------------------------------------------------------------
func hit_rabbit(oppressor: Spatial):
	emit_signal("hit")

	# escape!
	var vec: Vector3 = global_transform.origin - oppressor.global_transform.origin
	vec.y = 0.0
	vec = vec.normalized()
	goal = global_transform.origin + vec * rand_range(5.0, 20.0)
	state_current = States.STATE_ESCAPE

	# play animation
	node_animation_player.play("hit")
	yield(node_animation_player, "animation_finished")
	node_animation_player.play("wiggle")


# ----------------------------------------------------------------------------
func rip_rabbit():
	emit_signal("dead")

	# don't move
	goal = global_transform.origin
	is_dead = true

	# play animation and die
	node_animation_player.play("rip")
	yield(node_animation_player, "animation_finished")
	queue_free()


# ----------------------------------------------------------------------------
func find_closest_vegetable(target: Vector3) -> Spatial:
	var vege_list := get_tree().get_nodes_in_group("veggies")
	if vege_list.size() == 0:
		return null

	var closest: Spatial = null
	var distance: float = INF
	var check: float

	for vege in vege_list:
		check = target.distance_squared_to(vege.global_transform.origin)
		if distance > check:
			distance = check
			closest = vege

	return closest


# ----------------------------------------------------------------------------
func find_random_vegetable() -> Spatial:
	var vege_list := get_tree().get_nodes_in_group("veggies")
	if vege_list.size() == 0:
		return null
	return vege_list[randi() % vege_list.size()]


# ----------------------------------------------------------------------------
func get_veggie_goal():
	chosen_vegetable = find_random_vegetable()
	if chosen_vegetable:
		set_goal(chosen_vegetable)
		return States.STATE_FOLLOW
	else:
		goal = global_transform.origin
		return States.STATE_WANDER


# ----------------------------------------------------------------------------
func _on_Timer_timeout() -> void:
	if state_current != States.STATE_EAT:
		return

	if chosen_vegetable and is_instance_valid(chosen_vegetable):
		chosen_vegetable.one_bite()
		node_timer.start()
	else:
		chosen_vegetable = null
