/*
	File: scripts/ship_control.nut
	Author: P. Blanche - F. Gutherz
*/

/*!
	@short	ShipControl
	@author	P. Blanche - F. Gutherz
*/
class	ShipControl
{
	scene					=	0
	ship_direction			=	0
	mouse_device			=	0
	control_function		=	0		//	The current function that handles the control scheme

	/*!
		@short	OnUpdate
		Called each frame.
	*/
	function	Update()
	{
		control_function()
	}

	function	NewOrbitControl()
	{
		local	mx = DeviceInputValue(mouse_device, DeviceAxisX)
		local	my = DeviceInputValue(mouse_device, DeviceAxisY)

		local	ship_screen_position, player_item

		player_item = SceneGetScriptInstance(scene).player_item
		ship_screen_position = CameraWorldToScreen(SceneGetScriptInstance(scene).camera_handler.camera, g_render, ItemGetPosition(player_item))

		ship_direction = Vector()
		ship_direction.x = mx - ship_screen_position.x
		ship_direction.z = -(my - ship_screen_position.y)
		ship_direction = ship_direction.Normalize()

		if( DeviceIsKeyDown(mouse_device, KeyButton0))
		{
			local	ship_euler = EulerFromDirection(ship_direction)
			ItemGetScriptInstance(player_item).SetOrientation(ship_euler)
			ItemGetScriptInstance(player_item).SetThrustUp()
		}
	}

	constructor(_scene)
	{
		scene = _scene
		ship_direction = g_zero_vector
		mouse_device = GetInputDevice("mouse")
		control_function = NewOrbitControl
	}
}
