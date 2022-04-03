extends KinematicBody
class_name Player


# ----------------------------------------------------------------------------
const GRAVITY := -20.0
const MAX_SPEED := 8.0
const ACCEL := 10.0
const DEACCEL := 12.0
const SENSITIVITY := 0.003


# ----------------------------------------------------------------------------
var node_pivot: Spatial
var node_camera: Camera
var direction: Vector3
var velocity: Vector3
var is_dead: bool


# ----------------------------------------------------------------------------
func _ready() -> void:
	node_pivot = $Pivot as Spatial
	node_camera = $Pivot/Camera as Camera
	direction = Vector3.ZERO
	velocity = Vector3.ZERO
	is_dead = false

	# capture mouse inside screen
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# ----------------------------------------------------------------------------
func _physics_process(_delta: float) -> void:
	if not is_dead:
		process_input(_delta)
		process_movement(_delta)


# ----------------------------------------------------------------------------
func process_input(_delta: float) -> void:
	var move: Vector2 = Vector2.ZERO
	var cam: Transform = node_camera.get_global_transform()

	# keyboard
	if Input.is_action_pressed("move_forward"):
		move.y += 1.0
	if Input.is_action_pressed("move_backward"):
		move.y -= 1.0
	if Input.is_action_pressed("strafe_left"):
		move.x -= 1.0
	if Input.is_action_pressed("strafe_right"):
		move.x += 1.0

	# calculate direction
	move = move.normalized()
	direction = Vector3.ZERO
	direction += -cam.basis.z.normalized() * move.y
	direction += cam.basis.x.normalized() * move.x


# ----------------------------------------------------------------------------
func process_movement(_delta: float) -> void:
	# prepare direction
	direction.y = 0.0
	direction = direction.normalized()

	# target move vector
	var target := direction * MAX_SPEED

	# temporary velocity
	var temp_velocity := velocity
	temp_velocity.y = 0.0

	# acceleration / deacceleration
	var accel: float
	if direction.dot(temp_velocity) > 0.0:
		accel = ACCEL
	else:
		accel = DEACCEL

	# interpolate velocity to target
	temp_velocity = temp_velocity.linear_interpolate(target, accel * _delta)

	# update velocity
	velocity.x = temp_velocity.x
	velocity.y += GRAVITY * _delta
	velocity.z = temp_velocity.z

	# make a move
	velocity = move_and_slide(velocity, Vector3.UP, true)


# ----------------------------------------------------------------------------
func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * SENSITIVITY)
		node_pivot.rotate_x(-event.relative.y * SENSITIVITY)
		node_pivot.rotation.x = clamp(node_pivot.rotation.x, -1.2, 1.0)
