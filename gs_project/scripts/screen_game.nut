/*
	File: scripts/utils/scene_game.nut
	Author: P. Blanche - F. Gutherz
*/

Include("scripts/utils/scene_game_base.nut")
Include("scripts/camera_game.nut")
Include("scripts/starfield.nut")
Include("scripts/ship_control.nut")

/*!
	@short	SceneGame
	@author	P. Blanche - F. Gutherz
*/
class	SceneGame	extends SceneGameBase
{
	player_item				=	0
	camera_handler			=	0
	starfield_handler		=	0
	ship_control_handler	=	0

	ship_direction			=	0

	render_user_callback	=	0

	/*!
		@short	OnUpdate
		Called each frame.
	*/
	function	OnUpdate(scene)
	{
		local	mouse_device = GetInputDevice("mouse")
	
		ship_control_handler.Update()

		local	mouse_wheel = DeviceInputValue(mouse_device, DeviceAxisRotY)
		camera_handler.OffsetCameraY(mouse_wheel * Mtr(-15.0))
		starfield_handler.SetSize(camera_handler.target_pos_offset.y)

		camera_handler.Update(player_item)
	}

	function	OnRenderUser(scene)
	{
		RendererSetIdentityWorldMatrix(g_render)
		starfield_handler.Update(camera_handler.position)

		foreach(_callback in render_user_callback)
			_callback["RenderUser"](scene)
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
		ship_control_handler = ShipControl(scene)
		starfield_handler = Starfield()

		render_user_callback = []
		ship_direction = g_zero_vector
	}
}
