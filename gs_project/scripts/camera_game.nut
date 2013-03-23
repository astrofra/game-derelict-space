/*
	File: scripts/camera_game.nut
	Author: P. Blanche - F. Gutherz
*/

/*!
	@short	GameCamera
	@author	P. Blanche - F. Gutherz
*/
class	CameraGame
{

	camera				=	0
	camera_item			=	0
	position			=	0
	pos_offset			=	0
	target_pos_offset	=	0
	speed				=	5.0
	scene				=	0

	constructor(_scene)
	{
		position = g_zero_vector
		scene = _scene
		camera = SceneAddCamera(scene, "camera_game")
		camera_item = CameraGetItem(camera)
		pos_offset = Vector(0,Mtr(50.0),0)
		target_pos_offset = clone(pos_offset)
		CameraSetFov(camera, Deg(50.0))
		ItemSetPosition(camera_item, pos_offset)
		ItemSetRotation(camera_item, Vector(Deg(90),0,0))
		SceneSetCurrentCamera(scene, camera)
		ItemRegistrySetKey (camera_item, "PostProcess:Bloom:Strength;", 5.0)
		ItemRegistrySetKey (camera_item, "PostProcess:Bloom:Radius;", 25.0)
		ItemRegistrySetKey (camera_item, "PostProcess:Bloom:Threshold;", 0.85)
	}

	function	OffsetCameraY(dt_y)
	{
		target_pos_offset.y += dt_y
		target_pos_offset.y = Clamp(target_pos_offset.y, Mtr(25.0), Mtr(250.0))
	}

	function	Update(item_to_follow)
	{
		local	target_pos = ItemGetWorldPosition(item_to_follow)
		local	dir = target_pos - position
		dir = dir.Scale(g_dt_frame * speed)
		position += dir

		local	dt_offset = target_pos_offset - pos_offset
		dt_offset = dt_offset.Scale(g_dt_frame)
		pos_offset += dt_offset

		ItemSetPosition(camera_item, position + pos_offset)
		//local	tilt_angle = RangeAdjust(dir.Len(), 0.0, 5.0, 0.0, 15.0)
		//ItemSetRotation(camera_item, Vector(DegreeToRadian(90.0 + tilt_angle), 0.0, 0.0))
	}
}
