/*
	File: scripts/utils/scene_game.nut
	Author: P. Blanche - F. Gutherz
*/

Include("scripts/utils/scene_game_base.nut")
Include("scripts/camera_game.nut")
Include("scripts/starfield.nut")

/*!
	@short	SceneGame
	@author	P. Blanche - F. Gutherz
*/
class	SceneGame	extends SceneGameBase
{
	player_item				=	0
	camera_handler			=	0
	starfield_handler		=	0

	ship_direction			=	0

	/*!
		@short	OnUpdate
		Called each frame.
	*/
	function	OnUpdate(scene)
	{
		local	mouse_device = GetInputDevice("mouse")
		local	mx = DeviceInputValue(mouse_device, DeviceAxisX)
		local	my = DeviceInputValue(mouse_device, DeviceAxisY)

		local	ship_screen_position
		ship_screen_position = CameraWorldToScreen(camera_handler.camera, g_render, ItemGetPosition(player_item))
//		print("mx, shipx = " + mx.tostring() + ", " + ship_screen_position.x.tostring())

		ship_direction = Vector()
		ship_direction.x = mx - ship_screen_position.x
		ship_direction.z = -(my - ship_screen_position.y)
		ship_direction = ship_direction.Normalize()

		local	ship_euler = EulerFromDirection(ship_direction)
		ItemGetScriptInstance(player_item).target_direction = ship_direction //ship_euler
	}

	function	OnRenderUser(scene)
	{
		RendererSetIdentityWorldMatrix(g_render)
		starfield_handler.Update(camera_handler.position)

		local	ship_position = ItemGetWorldPosition(player_item)
		RendererDrawLine(g_render, ship_position, ship_position + ship_direction.Scale(10.0))
	}

	/*!
		@short	OnSetup
		Called when the scene is about to be setup.
	*/
	function	OnSetup(scene)
	{
		base.OnSetup(scene)
		camera_handler = CameraGame(scene)
		player_item = SceneFindItem(scene, "ship")
		starfield_handler = Starfield()

		ship_direction = g_zero_vector
	}
}
