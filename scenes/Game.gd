extends Spatial


# ----------------------------------------------------------------------------
export var scene_rabbit: PackedScene


# ----------------------------------------------------------------------------
const MAX_RABBITS = 32


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
var game_over: bool

var goal_score: int
var goal_veggies: int


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

	game_ticks = 0
	game_over = false

	goal_score = 0
	goal_veggies = node_vegetables.get_child_count()
	updateHud()

	# start game timer
	node_gametimer.start()

	# connect vegies
	var vegies = node_vegetables.get_children()
	for vegie in vegies:
		vegie.connect("vegetable_eaten", self, "_on_vegetable_eaten")


# ----------------------------------------------------------------------------
func _process(_delta: float) -> void:

	if Input.is_action_just_released("exit_game"):
		## get_tree().quit()
		get_tree().change_scene("res://scenes/Menu.tscn")
		return

	if goal_veggies <= 0 and not node_player.is_dead:
		$HUD/GameOver.visible = true
		$Entities.pause_mode = Node.PAUSE_MODE_STOP
		node_player.is_dead = true


# ----------------------------------------------------------------------------
func _physics_process(_delta: float) -> void:
	pass


# ----------------------------------------------------------------------------
func _on_GameTimer_timeout() -> void:
	game_ticks += 1
	# print("tick " + str(game_ticks))

	if game_ticks % 3 == 0:
		spawn_rabbit()



# ----------------------------------------------------------------------------
func spawn_rabbit() -> void:
		if node_rabbits.get_child_count() >= MAX_RABBITS:
			return

		var spawn_list := node_spawn_rabbits.get_children()
		var spawn = spawn_list[randi() % spawn_list.size()]

		var rabbit := scene_rabbit.instance() as Enemy
		node_rabbits.add_child(rabbit)
		rabbit.global_transform.origin = spawn.global_transform.origin
		rabbit.connect("hit", self, "_on_Rabbit_Hit")
		rabbit.connect("dead", self, "_on_Rabbit_Dead")


# ----------------------------------------------------------------------------
func _on_Rabbit_Hit():
	goal_score += 10
	updateHud()


# ----------------------------------------------------------------------------
func _on_Rabbit_Dead():
	goal_score += 100
	updateHud()


# ----------------------------------------------------------------------------
func _on_vegetable_eaten():
	goal_veggies -= 1
	updateHud()

# ----------------------------------------------------------------------------
func updateHud():
	$HUD/Score.text = "Score: " + str(goal_score)
	$HUD/Veggies.text = "Veggies: " + str(goal_veggies)
