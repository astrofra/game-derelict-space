/*
	File: scripts/ship_control.nut
	Author: P. Blanche - F. Gutherz
*/

Include("scripts/utils/utils.nut")

/*!
	@short	ShipControl
	@author	P. Blanche - F. Gutherz
*/
class	ShipControl
{
	scene					=	0

	mouse_device			=	0
	keyboard_device			=	0
	mx						=	0
	my						=	0

	callbacks				=	0		//	The current function that handles the control scheme
	current_callback_index	=	0

	ship_direction			=	0
	target_direction		=	0
	display_target_dir		=	0
	ship_screen_position	=	0
	player_item				=	0

	/*!
		@short	OnUpdate
		Called each frame.
	*/
	function	Update()
	{
		mx = DeviceInputValue(mouse_device, DeviceAxisX)
		my = DeviceInputValue(mouse_device, DeviceAxisY)

		if(!g_WindowsManager.mouse_locked_by_ui)
		{
			ship_screen_position = CameraWorldToScreen(SceneGetScriptInstance(scene).camera_handler.camera, g_render, ItemGetPosition(player_item))
			if ("control_function" in callbacks[current_callback_index])	this[callbacks[current_callback_index].control_function]()
		}
	}

	function	RenderUser(scene)
	{
		if ("render_function" in callbacks[current_callback_index])	this[callbacks[current_callback_index].render_function](scene)		
//		local	mouse_3d_pos = CameraScreenToWorld(SceneGetScriptInstance(scene).camera_handler.camera, g_render, mx, my)
//		RendererDrawCross(g_render, mouse_3d_pos)
//		RendererDrawLine(g_render, ship_screen_position, ship_screen_position + ship_direction.Scale(10.0))
	}

	/*
		New Orbit Scheme	
	*/
	function	NewOrbitControl()
	{
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

	function	NewOrbitRenderUser(scene)
	{
		local	ship_position = ItemGetWorldPosition(player_item)
		local	vector_front = ItemGetScriptInstance(player_item).vector_front
		RendererDrawLineColored(g_render, ship_position, ship_position + vector_front.Scale(1 + ItemGetScriptInstance(player_item).thrust), Vector(0.1,1.0,0.25))
	}

	function	NewOrbitShipSettings()
	{
		ItemGetScriptInstance(player_item).max_angular_speed = 5.0
		ItemGetScriptInstance(player_item).SetAngularDamping(1.0)
	}


	/*
		Pascal Blanche Scheme	
	*/
	function	BlancheControl()
	{
		ship_direction = Vector()
		ship_direction.x = mx - ship_screen_position.x
		ship_direction.z = -(my - ship_screen_position.y)
		ship_direction = ship_direction.Normalize()

		if(DeviceKeyPressed(mouse_device, KeyButton0) && !DeviceWasKeyDown(mouse_device, KeyButton0))
		{
			target_direction = clone(ship_direction)
			local	ship_euler = EulerFromDirection(target_direction)
			ItemGetScriptInstance(player_item).SetOrientation(ship_euler)
			ItemGetScriptInstance(player_item).SfxSetOrientationTarget()
		}

		display_target_dir += (target_direction - display_target_dir).Scale(10.0 * g_dt_frame)
		display_target_dir = display_target_dir.Normalize()

		if (DeviceIsKeyDown(keyboard_device, KeySpace))
			ItemGetScriptInstance(player_item).SetThrustUp()

	}

	function	BlancheRenderUser(scene)
	{
		local	ship_position = ItemGetWorldPosition(player_item)
		local	vector_front = ship_direction
		//RendererDrawLineColored(g_render, ship_position, ship_position + vector_front.Scale(10.0), g_vector_green)
		DrawCircleInXZPlane(ship_position, Mtr(10.0), g_vector_green, 15.0)
		DrawArrowInXZPlane(ship_position + display_target_dir.Scale(9.75), display_target_dir, Mtr(1.0), g_vector_green)
	}

	function	BlancheShipSettings()
	{
		ItemGetScriptInstance(player_item).max_angular_speed = 5.0
		ItemGetScriptInstance(player_item).SetAngularDamping(1.0)
	}

	function	ClickOnControl(_sprite)
	{
		print("ShipControl::ClickOnControl() _sprite = " + _sprite)

		foreach(_idx, _callback in callbacks)
		{
			_callback.button.RefreshValueText(false)
			if (_callback.button == _sprite)
				current_callback_index = _idx
		}

		_sprite.RefreshValueText(true)
	}

	constructor(_scene)
	{
		scene = _scene
		ship_direction = Vector(0,0,1)
		target_direction = Vector(0,0,1)
		display_target_dir = target_direction
		mouse_device = GetInputDevice("mouse")
		keyboard_device = GetInputDevice("keyboard")
		player_item = SceneGetScriptInstance(scene).player_item

		callbacks = []
		callbacks.append({button = 0, name = tr("LaBlanche Control"),	control_function = "BlancheControl",	render_function = "BlancheRenderUser"})
		callbacks.append({button = 0, name = tr("New Orbit Control"),	control_function = "NewOrbitControl",	render_function = "NewOrbitRenderUser"})
		callbacks.append({button = 0, name = tr("Null Control")})

		local	top_window = g_WindowsManager.CreateVerticalSizer(0, 1000)
		top_window.SetPos(Vector(8, 8, 0))

		for(local n = 0; n < callbacks.len();n++)
		{
			local	_bt
 			_bt = g_WindowsManager.CreateCheckButton(top_window, callbacks[n].name, current_callback_index == n?true:false, this, "ClickOnControl")
			_bt.authorize_resize = false
			callbacks[n].button = _bt
		}

		SceneGetScriptInstance(g_scene).render_user_callback.append(this)
	}
}
