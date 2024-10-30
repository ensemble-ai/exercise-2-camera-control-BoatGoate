class_name PositionLockLerp
extends CameraControllerBase

@export var follow_speed:float = 0.9
@export var catch_up:float = 1.1
@export var leash_distance:float = 20

func _ready() -> void:
	super()
	global_position = target.global_position
	

func _process(delta: float) -> void:
	if !current:
		return
	
	if draw_camera_logic:
		draw_logic()
	
	var tpos = target.global_position
	var cpos = global_position
	var direction:Vector3 = (tpos - cpos).normalized()
	
	var camera_speed: float = target.BASE_SPEED * follow_speed
	if Input.is_action_pressed("ui_accept"):
		camera_speed = target.HYPER_SPEED * catch_up

	
	if abs(tpos.distance_to(cpos)) < leash_distance:
		print("if")
		global_position += direction * camera_speed * delta
	else:
		print("else")
		global_position += direction * camera_speed * 1.2 * delta

	super(delta)


func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	var line_length:float = 5
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	
	#left to right
	immediate_mesh.surface_add_vertex(Vector3(-line_length, 0, 0))
	immediate_mesh.surface_add_vertex(Vector3(line_length, 0, 0))
	
	#top to bottom
	immediate_mesh.surface_add_vertex(Vector3(0, 0, -line_length))
	immediate_mesh.surface_add_vertex(Vector3(0, 0, line_length))
	

	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.WHITE
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	#mesh is freed after one update of _process
	await get_tree().process_frame
	mesh_instance.queue_free()
