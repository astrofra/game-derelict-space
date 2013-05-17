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
	mouse_pos_3d			=	0
	mouse_dir_3d			=	0

	callbacks				=	0		//	The current function that handles the control scheme
	current_callback_index	=	0
	autopilot_item_target	=	0

	gear_button				=	0

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

		mouse_pos_3d = CameraScreenToWorld(SceneGetScriptInstance(scene).camera_handler.camera, g_render, mx, my)
		local	_cam_pos = ItemGetPosition(CameraGetItem(SceneGetScriptInstance(scene).camera_handler.camera))
		mouse_dir_3d = (mouse_pos_3d - _cam_pos).Normalize()

		if(!g_WindowsManager.mouse_locked_by_ui)
		{
			ship_screen_position = CameraWorldToScreen(SceneGetScriptInstance(scene).camera_handler.camera, g_render, ItemGetPosition(player_item))
			if ("control_function" in callbacks[current_callback_index])	this[callbacks[current_callback_index].control_function]()
		}

//		if (autopilot_item_target != 0 && !ObjectIsValid(autopilot_item_target))
//			autopilot_item_target = 0

		if (autopilot_item_target != 0)
			this[callbacks[current_callback_index].autopilot_function]()
	}

	/*
		@short	TestAutopilotTargetValidity
		Test if the item passed as parameter
		if the current target of the autopilot
	*/
	function	TestAutopilotTargetValidity(target_item)
	{
		if (autopilot_item_target == 0)
			return

		if (ObjectIsSame(target_item, autopilot_item_target))
		{
			ItemGetScriptInstance(autopilot_item_target).focus = false
			autopilot_item_target = 0
		}
	}

	function	RenderUser(scene)
	{
		if ("render_function" in callbacks[current_callback_index])	this[callbacks[current_callback_index].render_function](scene)		
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

		//	Mouse click
		if(DeviceKeyPressed(mouse_device, KeyButton0) && !DeviceWasKeyDown(mouse_device, KeyButton0) && !g_WindowsManager.mouse_locked_by_ui)
		{
			if (autopilot_item_target != 0) ItemGetScriptInstance(autopilot_item_target).focus = false

			local	hit = SceneCollisionRaytrace(g_scene, mouse_pos_3d, mouse_dir_3d, -1, CollisionTraceAll, Mtr(500.0))

			if (hit.hit)
			{
				//	Yes ? Set it as a target
				local	hit_item = hit.item
				if (ItemGetName(hit_item).find("asteroid") != null)
				{
					autopilot_item_target = hit_item
					ItemGetScriptInstance(autopilot_item_target).focus = true
				}
			}
			else
			{
				//	No ? Set a new direction
				target_direction = clone(ship_direction)
				local	ship_euler = EulerFromDirection(target_direction)
				ItemGetScriptInstance(player_item).SetOrientation(ship_euler)
				ItemGetScriptInstance(player_item).audio_handler.SfxSetOrientationTarget()
				autopilot_item_target = 0
			}
		}

		display_target_dir += (target_direction - display_target_dir).Scale(10.0 * g_dt_frame)
		display_target_dir = display_target_dir.Normalize()

		//	Arrows
		if (DeviceIsKeyDown(keyboard_device, KeyUpArrow))
			ItemGetScriptInstance(player_item).SetThrustUp()
		else
		if (DeviceIsKeyDown(keyboard_device, KeyDownArrow))
			ItemGetScriptInstance(player_item).SetThrustDown()

		if (autopilot_item_target != 0)
		{
			if (DeviceIsKeyDown(keyboard_device, KeyLeftArrow))
			{
				ItemGetScriptInstance(player_item).StrafeLeft()
			}
			else
			if (DeviceIsKeyDown(keyboard_device, KeyRightArrow))
			{
				ItemGetScriptInstance(player_item).StrafeRight()
			}		
		}
		else
		{
			local	keyb_arrow_angular_speed = 5.0 * RangeAdjust(ItemGetScriptInstance(player_item).max_angular_speed, 0.1, 90.0, 0.1, 0.9) 
			if (DeviceIsKeyDown(keyboard_device, KeyLeftArrow))
			{
				ItemGetScriptInstance(player_item).IncreaseOrientationAngle(-keyb_arrow_angular_speed)
				local	_new_orientation = ItemGetScriptInstance(player_item).target_orientation
				local	_a_offset = Deg(90.0)
				display_target_dir = Vector(-cos(_new_orientation.y + _a_offset),0,sin(_new_orientation.y + _a_offset)).Normalize()
				target_direction = clone(display_target_dir)
			}
			else
			if (DeviceIsKeyDown(keyboard_device, KeyRightArrow))
			{
				ItemGetScriptInstance(player_item).IncreaseOrientationAngle(keyb_arrow_angular_speed)
				local	_new_orientation = ItemGetScriptInstance(player_item).target_orientation
				local	_a_offset = Deg(90.0)
				display_target_dir = Vector(-cos(_new_orientation.y + _a_offset),0,sin(_new_orientation.y + _a_offset)).Normalize()
				target_direction = clone(display_target_dir)
			}
		}

		//	Weaponry
		if (DeviceIsKeyDown(keyboard_device, KeyX)	||
			DeviceIsKeyDown(keyboard_device, KeyRAlt) ||
			DeviceIsKeyDown(keyboard_device, KeyNumpad0))
			ItemGetScriptInstance(player_item).Shoot()

		//	Gears
		if (DeviceIsKeyDown(keyboard_device, KeyF1) && !DeviceWasKeyDown(keyboard_device, KeyF1))
			ClickOnGear(gear_button[0])
		else
		if (DeviceIsKeyDown(keyboard_device, KeyF2) && !DeviceWasKeyDown(keyboard_device, KeyF2))
			ClickOnGear(gear_button[1])
		else
		if (DeviceIsKeyDown(keyboard_device, KeyF3) && !DeviceWasKeyDown(keyboard_device, KeyF3))
			ClickOnGear(gear_button[2])

	}

	function	BlancheAutopilot()
	{
		target_direction = (ItemGetWorldPosition(autopilot_item_target) - ItemGetScriptInstance(player_item).position).Normalize()
		local	ship_euler = EulerFromDirection(target_direction)
		ItemGetScriptInstance(player_item).SetOrientation(ship_euler)
	}

	function	BlancheRenderUser(scene)
	{
		local	ship_position = ItemGetWorldPosition(player_item)
		local	vector_front = ship_direction

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

	function	ClickOnGear(_sprite)
	{
		print("ShipControl::ClickOnGear() _sprite = " + _sprite)

		for(local n = 0; n < 3; n++)
		{
			gear_button[n].RefreshValueText(false)
			if (gear_button[n] == _sprite)
				ItemGetScriptInstance(player_item).FetchShipSettings(n)
		}

		_sprite.RefreshValueText(true)
	}

	constructor(_scene)
	{
		scene = _scene
		mouse_pos_3d = g_zero_vector
		ship_direction = Vector(0,0,1)
		target_direction = Vector(0,0,1)
		display_target_dir = target_direction
		mouse_device = GetInputDevice("mouse")
		keyboard_device = GetInputDevice("keyboard")
		player_item = SceneGetScriptInstance(scene).player_item

		callbacks = []
		callbacks.append({button = 0, name = tr("LaBlanche"),	control_function = "BlancheControl",	autopilot_function = "BlancheAutopilot",	render_function = "BlancheRenderUser"})
//		callbacks.append({button = 0, name = tr("Null Ctrl")})

		local	top_window = g_WindowsManager.CreateVerticalSizer(0, 1000)
		top_window.SetParent(SceneGetScriptInstance(g_scene).master_ui_sprite)
		top_window.SetPos(Vector(8, 8, 0))

		for(local n = 0; n < callbacks.len();n++)
		{
			local	_bt
 			_bt = g_WindowsManager.CreateCheckButton(top_window, callbacks[n].name, current_callback_index == n?true:false, this, "ClickOnControl")
			_bt.authorize_resize = false
			callbacks[n].button = _bt
		}

		local	gear_window = g_WindowsManager.CreateVerticalSizer(0, 1000)
		gear_window.SetParent(SceneGetScriptInstance(g_scene).master_ui_sprite)
		gear_window.SetPos(Vector(1280 - 140, 8, 0))

		gear_button = []
		for(local n = 0; n < 3;n++)
		{
			local	_bt
 			_bt = g_WindowsManager.CreateCheckButton(gear_window, tr("Gear") + " #" + n.tostring() , n == 0?true:false, this, "ClickOnGear")
			_bt.authorize_resize = false
			gear_button.append(_bt)
		}

		SceneGetScriptInstance(g_scene).render_user_callback.append(this)
	}

	/*
		New Orbit Scheme	
	*/
	function	NewOrbitControl()
	{
	}

	function	NewOrbitRenderUser(scene)
	{
	}

	function	NewOrbitShipSettings()
	{
	}
}
