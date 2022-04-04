extends KinematicBody
class_name Enemy


# ----------------------------------------------------------------------------
signal hit
signal dead


# ----------------------------------------------------------------------------
enum States {
	STATE_SPAWN, # moment of birth
	STATE_WANDER, # wandering
	STATE_FOLLOW, # follow path to target
	STATE_ESCAPE, # escape from player
	STATE_ATTACK, # attack player
	STATE_HURT, # hurt by player
	STATE_EAT # eat crops
}

# ----------------------------------------------------------------------------
var node_animation_player: AnimationPlayer


# ----------------------------------------------------------------------------
var direction: Vector3 # direction vector
var velocity: Vector3 # current velocity vector
var goal: Vector3 # goal coordinates
var gravity: float # gravity for enemy
var rotation_speed: float # model rotation speed
var move_speed: float # enemy speed
var move_accel: float # enemy acceleration speed
var move_deaccel: float # enemy braking speed
var proximity_len_squared: float # minimal distance to target (squared for optimization)
var is_dead: bool # dead or alive
var is_flying: bool # affected by gravity
var state_current # state from States
var health: int # health


# ----------------------------------------------------------------------------
func _ready() -> void:
	node_animation_player = $AnimationPlayer as AnimationPlayer
	direction = Vector3.ZERO
	velocity = Vector3.ZERO
	goal = Vector3.ZERO
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	rotation_speed = 10.0
	move_speed = 1.0
	move_accel = 1.0
	move_deaccel = 1.0
	proximity_len_squared = 1.0
	is_dead = false
	is_flying = false
	state_current = States.STATE_SPAWN
	health = 100


# ----------------------------------------------------------------------------
func _physics_process(_delta: float) -> void:
	if not is_dead:
		process_ai(_delta)
		process_movement(_delta)


# ----------------------------------------------------------------------------
func process_ai(_delta: float) -> void:
	pass


# ----------------------------------------------------------------------------
func process_movement(_delta: float) -> void:
	var distance_squared: float

	# get direction and distance
	direction = goal - global_transform.origin
	distance_squared = direction.length_squared()

	# prepare direction
	direction.y = 0.0
	direction = direction.normalized()

	# target move vector
	var target: Vector3
	if distance_squared > proximity_len_squared:
		target = direction * move_speed
		if state_current == States.STATE_ESCAPE:
			target *= 2.0
	else:
		target = Vector3.ZERO

	# temporary velocity
	var temp_velocity := velocity
	temp_velocity.y = 0.0

	# acceleration / deacceleration
	var accel: float
	if direction.dot(temp_velocity) > 0.0:
		accel = move_accel
	else:
		accel = move_deaccel

	# interpolate velocity to target
	temp_velocity = temp_velocity.linear_interpolate(target, accel * _delta)

	# update velocity
	velocity.x = temp_velocity.x
	velocity.z = temp_velocity.z
	if not is_flying:
		velocity.y -= gravity * _delta

	# make a move
	velocity = move_and_slide(velocity, Vector3.UP, true)


# ----------------------------------------------------------------------------
func set_goal(object: Spatial):
	goal = object.global_transform.origin
