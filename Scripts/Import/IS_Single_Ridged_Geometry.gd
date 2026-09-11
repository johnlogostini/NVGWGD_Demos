@tool
extends EditorScenePostImport


func _post_import(scene: Node) -> Object:
	var source_file := get_source_file()
	var file_name := source_file.get_file().get_basename()

	# Already a mesh, just rename it.
	if scene is MeshInstance3D:
		scene.name = file_name
		return scene

	# Find the mesh in the imported scene.
	var meshes: Array[MeshInstance3D] = []
	_find_meshes(scene, meshes)

	if meshes.is_empty():
		push_error("No MeshInstance3D found in: " + source_file)
		return scene

	if meshes.size() > 1:
		push_error(
			"Found multiple meshes in '%s'. Expected one."
			% file_name
		)
		return scene

	var mesh_instance := meshes[0]

	# Keep the original transform.
	var final_transform := Transform3D.IDENTITY
	var current: Node3D = mesh_instance

	while current != null and current != scene:
		final_transform = current.transform * final_transform
		current = current.get_parent() as Node3D

	mesh_instance.transform = final_transform

	# Use the FBX filename as the node name.
	mesh_instance.name = file_name

	# Remove it from the old hierarchy.
	if mesh_instance.get_parent() != null:
		mesh_instance.get_parent().remove_child(mesh_instance)

	return mesh_instance


func _find_meshes(node: Node, result: Array[MeshInstance3D]) -> void:
	if node is MeshInstance3D:
		result.append(node)

	for child in node.get_children():
		_find_meshes(child, result)
