class_name SpeedUpPushZone
extends CameraControllerBase

@export var push_ratio:float = 0.4
@export var pushbox_top_left:Vector2 = Vector2(-10,10)
@export var pushbox_bottom_right:Vector2 = Vector2(10,-10)
@export var speedup_zone_top_left:Vector2 = Vector2(-4,4)
@export var speedup_zone_bottom_right:Vector2 = Vector2(4,-4)

var push_left: float = pushbox_top_left.x
var push_top: float = pushbox_top_left.y
var push_right: float = pushbox_bottom_right.x
var push_bottom: float = pushbox_bottom_right.y

var speedup_left: float = speedup_zone_top_left.x
var speedup_top: float = speedup_zone_top_left.y
var speedup_right: float = speedup_zone_bottom_right.x
var speedup_bottom: float = speedup_zone_bottom_right.y


func _ready() -> void:
	super()
	position = target.position
	

func _process(delta: float) -> void:
	if !current:
		return
	
	if draw_camera_logic:
		draw_logic()

	var camera_current_speed = target.BASE_SPEED
	if Input.is_action_pressed("ui_accept"):
		camera_current_speed = target.HYPER_SPEED
	
	var cpos = global_position
	var tpos = target.global_position
	
	#pushbox check
	#left
	var diff_between_left_edges = (tpos.x - target.WIDTH / 2.0) - (cpos.x + push_left)
	if diff_between_left_edges < 0:
		global_position.x += diff_between_left_edges
	#right
	var diff_between_right_edges = (tpos.x + target.WIDTH / 2.0) - (cpos.x + push_right)
	if diff_between_right_edges > 0:
		global_position.x += diff_between_right_edges
	#top
	var diff_between_top_edges = (tpos.z + target.HEIGHT / 2.0) - (cpos.z + push_top)
	if diff_between_top_edges > 0:
		global_position.z += diff_between_top_edges
	#bottom
	var diff_between_bottom_edges = (tpos.z - target.HEIGHT / 2.0) - (cpos.z + push_bottom)
	if diff_between_bottom_edges < 0:
		global_position.z += diff_between_bottom_edges

	#
	print("Player: ",target.velocity)
	print("camera: ",Vector3(1,0,0) * camera_current_speed * push_ratio * delta)
	var horizonal_distance = tpos.x - cpos.x
	var vertical_distance = cpos.z - tpos.z
	
	#Speedup zone
	if horizonal_distance > speedup_right and horizonal_distance < push_right and target.velocity.x > 0:
		global_position += Vector3(1,0,0) * camera_current_speed * push_ratio * delta
	if horizonal_distance < speedup_left and horizonal_distance > push_left and target.velocity.x < 0:
		global_position += Vector3(-1,0,0) * camera_current_speed * push_ratio * delta
	
	if vertical_distance > speedup_top and vertical_distance < push_top and target.velocity.z < 0 :
		global_position += Vector3(0,0,-1) * camera_current_speed * push_ratio * delta
	if vertical_distance < speedup_bottom and vertical_distance > push_bottom and target.velocity.z > 0 :
		global_position += Vector3(0,0,1) * camera_current_speed * push_ratio * delta
	
	super(delta)


func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)

	#Draw push box
	immediate_mesh.surface_add_vertex(Vector3(push_left, 0, push_top))
	immediate_mesh.surface_add_vertex(Vector3(push_left, 0, push_bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(push_left, 0, push_bottom))
	immediate_mesh.surface_add_vertex(Vector3(push_right, 0, push_bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(push_right, 0, push_bottom))
	immediate_mesh.surface_add_vertex(Vector3(push_right, 0, push_top))
	
	immediate_mesh.surface_add_vertex(Vector3(push_right, 0, push_top))
	immediate_mesh.surface_add_vertex(Vector3(push_left, 0, push_top))
	
	#Draw speedup zone
	immediate_mesh.surface_add_vertex(Vector3(speedup_left, 0, speedup_top))
	immediate_mesh.surface_add_vertex(Vector3(speedup_left, 0, speedup_bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(speedup_left, 0, speedup_bottom))
	immediate_mesh.surface_add_vertex(Vector3(speedup_right, 0, speedup_bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(speedup_right, 0, speedup_bottom))
	immediate_mesh.surface_add_vertex(Vector3(speedup_right, 0, speedup_top))
	
	immediate_mesh.surface_add_vertex(Vector3(speedup_right, 0, speedup_top))
	immediate_mesh.surface_add_vertex(Vector3(speedup_left, 0, speedup_top))
	

	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.WHITE
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	#mesh is freed after one update of _process
	await get_tree().process_frame
	mesh_instance.queue_free()
