extends WorldEnvironment


# ----------------------------------------------------------------------------
func _ready() -> void:
	# match sun latitude and longitude with DirectionalLight "Sun" direction
	var node_sun := $Sun as DirectionalLight
	var forward: Vector3 = node_sun.global_transform.basis.z
	var sun_latitude: float = rad2deg(0.5 * PI - forward.angle_to(Vector3.UP))
	var sun_longitude: float = rad2deg(atan2(forward.x, -forward.z))
	var background := environment.background_sky as ProceduralSky
	background.sun_latitude = sun_latitude
	background.sun_longitude = sun_longitude
