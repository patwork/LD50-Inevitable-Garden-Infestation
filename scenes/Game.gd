extends Spatial


# ----------------------------------------------------------------------------
export var scene_rabbit: PackedScene

# ----------------------------------------------------------------------------
var node_gametimer: Timer
var node_spawntimer: Timer
var node_player: Player

var node_spawn_rabbits: Spatial
var node_spawn_wasps: Spatial

var node_rabbits: Spatial
var node_wasps: Spatial
var node_vegetables: Spatial

var game_ticks: int

# ----------------------------------------------------------------------------
func _ready() -> void:
	randomize()

	node_gametimer = $Timers/GameTimer as Timer
	node_spawntimer = $Timers/SpawnTimer as Timer
	node_player = $Entities/Player as Player

	node_spawn_rabbits = $Navigation/SpawnRabbits as Spatial
	node_spawn_wasps = $Navigation/SprawnWasps as Spatial

	node_rabbits = $Entities/Rabbits as Spatial
	node_wasps = $Entities/Wasps as Spatial
	node_vegetables = $Entities/Vegetables as Spatial

	# start game timer
	game_ticks = 0
	node_gametimer.start()


# ----------------------------------------------------------------------------
func _process(_delta: float) -> void:
	if Input.is_action_just_released("exit_game"):
		print("bye!")
		get_tree().quit()


# ----------------------------------------------------------------------------
func _physics_process(_delta: float) -> void:
	pass


# ----------------------------------------------------------------------------
func _on_GameTimer_timeout() -> void:
	game_ticks += 1
	print("tick " + str(game_ticks))

	if game_ticks % 3 == 0:
		spawn_rabbit()


# ----------------------------------------------------------------------------
func find_closest_vegetable(target: Vector3) -> Spatial:
	if node_vegetables.get_child_count() == 0:
		return null

	var vege_list := node_vegetables.get_children()
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
func find_random_vegetable(target: Vector3) -> Spatial:
	if node_vegetables.get_child_count() == 0:
		return null

	var vege_list := node_vegetables.get_children()
	return vege_list[randi() % vege_list.size()]


# ----------------------------------------------------------------------------
func spawn_rabbit() -> void:
		var spawn_list := node_spawn_rabbits.get_children()
		var spawn = spawn_list[randi() % spawn_list.size()]

		var vege := find_random_vegetable(spawn.global_transform.origin)
		if not vege:
			print_debug("no veggies")
			return

		var rabbit := scene_rabbit.instance() as Enemy
		node_rabbits.add_child(rabbit)
		rabbit.global_transform.origin = spawn.global_transform.origin
		rabbit.set_goal(vege)
