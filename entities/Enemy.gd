extends KinematicBody
class_name Enemy


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
var direction: Vector3 # direction vector
var velocity: Vector3 # current velocity vector
var goal: Vector3 # goal coordinates
var gravity: float # gravity for enemy
var rotation_speed: float # model rotation speed
var is_dead: bool # dead or alive
var is_flying: bool # affected by gravity
var state_current # state from States


# ----------------------------------------------------------------------------
func _ready() -> void:
	direction = Vector3.ZERO
	velocity = Vector3.ZERO
	goal = Vector3.ZERO
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	rotation_speed = 10.0
	is_dead = false
	is_flying = false
	state_current = States.STATE_SPAWN


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
	# update velocity
	## velocity.x = temp_velocity.x
	## velocity.z = temp_velocity.z
	if not is_flying:
		velocity.y -= gravity * _delta

	# make a move
	velocity = move_and_slide(velocity, Vector3.UP, true)


# ----------------------------------------------------------------------------
func set_goal(object: Spatial):
	goal = object.global_transform.origin
