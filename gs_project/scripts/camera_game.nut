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

	camera			=	0
	camera_item		=	0
	position		=	0
	pos_offset		=	0
	speed			=	15.0
	scene			=	0

	constructor(_scene)
	{
		position = g_zero_vector
		scene = _scene
		camera = SceneAddCamera(scene, "camera_game")
		camera_item = CameraGetItem(camera)
		pos_offset = Vector(0,Mtr(50.0),0)
		CameraSetFov(camera, Deg(35.0))
		ItemSetPosition(camera_item, pos_offset)
		ItemSetRotation(camera_item, Vector(Deg(90),0,0))
		SceneSetCurrentCamera(scene, camera)
	}

	function	Update(item_to_follow)
	{
		local	target_pos = ItemGetWorldPosition(item_to_follow)
		local	dir = target_pos - position
		dir = dir.Scale(g_dt_frame * speed)
		position += dir

		ItemSetPosition(camera_item, position + pos_offset)
	}
}
