/*
	File: scripts/ship.nut
	Author: P. Blanche - F. Gutherz
*/

Include("scripts/utils/physic_item_orbiting.nut")
Include("scripts/ship_audio.nut")
Include("scripts/ship_trails.nut")
Include("scripts/ship_cannon.nut")

/*!
	@short	Ship
	@author	P. Blanche - F. Gutherz
*/
class	Ship	extends	PhysicOrbitingItem
{


	max_speed				=	100.0	//	Unused, so far
	max_thrust				=	20.0
	max_angular_speed		=	1.2

	energy					=	100.0

	thrust					=	10.0
	orientation				=	0
	target_orientation		=	0
	target_direction		=	0
	thrust_strafe			=	0

	current_gear			=	0

	side_force				=	0
	banking					=	0.0
	target_banking			=	0.0

	banking_item			=	0

	physic_settings_slider	=	0

	audio_handler			=	0
	trails_handler			=	0
	cannon_handler			=	0

	/*!
		@short	OnUpdate
		Called during the scene update, each frame.
	*/
	function	OnUpdate(item)
	{
		if ("OnUpdate" in base)	base.OnUpdate(item)

		UpdateBanking()
		
		//	Automatically decrease the ship's thrusters.
		orientation = ItemGetRotation(item)
		if (thrust > 0.0)
			thrust	= Max(thrust -= g_dt_frame * 15.0, 0.0)
		else
		if (thrust < 0.0)
			thrust	= Min(thrust += g_dt_frame * 15.0, 0.0)

		if (thrust_strafe > 0.0)
			thrust_strafe = Max(thrust_strafe -= g_dt_frame * 15.0, 0.0)
		else
		if (thrust_strafe < 0.0)
			thrust_strafe = Min(thrust_strafe += g_dt_frame * 15.0, 0.0)

		UpdateLabel(item)

		foreach(_cannon in cannon_handler)
			_cannon.Update()

		audio_handler.PushVariable("thrust", thrust)
		audio_handler.PushVariable("thrust_strafe", thrust_strafe)
		audio_handler.PushVariable("max_thrust", max_thrust)
		audio_handler.Update()	//	UpdateAudio()
	}

	function	OnDelete(item)
	{
		audio_handler.Delete()
	}

	function	UpdateLabel(item)
	{
		local	_script = ItemGetScriptInstanceFromClass(item, "ItemLabel3D")
		if ("label" in _script)
			if (SceneGetScriptInstance(g_scene).hidden_ui)
				_script.label = ""
			else
				_script.label = "Speed = " + linear_velocity.Len().tointeger().tostring() + " m/s\nRot = " + RadianToDegree(orientation.y).tointeger().tostring() + " deg."
	}

	function	UpdateBanking()
	{
		local	_dt = target_banking - banking
		_dt *= g_dt_frame
		banking += _dt
		local	_angle = banking
		_angle = -Clamp(banking, -180.0, 180.0)
		ItemSetRotation(banking_item, Vector(0,0,DegreeToRadian(_angle)))
	}

	function	OnPhysicStep(item, dt)
	{
		if ("OnPhysicStep" in base)	base.OnPhysicStep(item, dt)

		local	body_matrix = ItemGetMatrix(item)

		ItemApplyLinearForce(item, front.Scale(mass * thrust))
		ItemApplyLinearForce(item, left.Scale(mass * thrust_strafe))

		//	Align the ship to the desired orientation
		//	If the reactor are ON
		local	should_rotate = false
		if (fabs(thrust) > 0.0)	should_rotate = true
		if (fabs(thrust_strafe) > 0.0)	should_rotate = true

//		if (should_rotate)
		{
			local	_torque, _torque_near_target
			_torque = target_orientation - orientation
			if (_torque.y > Deg(180.0) || _torque.y < Deg(-180.0))
				_torque = (orientation - target_orientation)

			_torque.y = Clamp(_torque.y, Deg(-max_angular_speed), Deg(max_angular_speed))

			local	_acc_feedback = RangeAdjust(Abs(_torque.y), Deg(max_angular_speed * 1.5), Deg(0.0), 0.0, 1.0)
			_acc_feedback = Pow(Clamp(_acc_feedback, 0.0, 1.0), 4.0)
			_torque -= ItemGetAngularVelocity(item).Scale(_acc_feedback)

			//	Velocity contribution
			local	_vel_factor = linear_velocity.Len()
			_vel_factor = RangeAdjust(_vel_factor, 1.0, 10.0, 0.05, 1.0)
			_vel_factor = Clamp(_vel_factor, 0.05, 1.0)

			//	Additionnal contribution, if the ship's velocity is close to zero,
			//	and if the ship's angle is very close to the target angle
			local	_add_angular_factor = 0.0
			_add_angular_factor = RadianToDegree(fabs(orientation.y - target_orientation.y))
			_add_angular_factor = 	Pow(Clamp(RangeAdjust(_add_angular_factor, 5.0, 1.0, 0.0, 1.0), 0.0, 1.0), 4.0) 
									* Clamp(RangeAdjust(_add_angular_factor, 1.0, 0.0, 1.0, 0.0), 0.0, 1.0)
									* (1.0 - _vel_factor)

			_vel_factor = Max(_vel_factor, _add_angular_factor)

			ItemApplyTorque(item, _torque.Scale(100.0 * mass * _vel_factor))
		}

		//	Banking
		local	_dot = 1.0 - front.Normalize().Dot(linear_velocity.Normalize())
		local	_cross = front.Normalize().Cross(linear_velocity.Normalize())
		if (_cross.y > 0.0) _dot *= -1.0

		side_force = body_matrix.GetLeft().Scale(_dot * 50.0)
		target_banking = _dot * linear_velocity.Len()		

		//	Camera Update
		SceneGetScriptInstance(g_scene).camera_handler.Update(SceneGetScriptInstance(g_scene).player_item)
	}

	/*!
		Navigation
		------------------------
	*/

	function	StrafeLeft()
	{
		thrust_strafe = Min(thrust_strafe += g_dt_frame * 60.0, max_thrust)
		if (fabs(thrust_strafe) > 0.1)	trails_handler.RecordTrails()
	}

	function	StrafeRight()
	{
		thrust_strafe = Max(thrust_strafe -= g_dt_frame * 60.0, -max_thrust)
		if (fabs(thrust_strafe) > 0.1)	trails_handler.RecordTrails()
	}


	function	SetOrientation(_euler)
	{
		target_orientation = _euler
	}

	function	IncreaseOrientationAngle(_angular_step)
	{
		target_orientation.y += DegreeToRadian(_angular_step)

		if (target_orientation.y >= Deg(180))
			target_orientation.y -= Deg(360)
		else
		if (target_orientation.y <= Deg(-180))
			target_orientation.y += Deg(360)
	}

	function	SetThrustUp()
	{
		thrust = Min(thrust += g_dt_frame * 60.0, max_thrust)
		if (thrust > 0.1)	trails_handler.RecordTrails()
	}

	function	SetThrustDown()
	{
		thrust	= Max(thrust -= g_dt_frame * 60.0 * 0.5, -max_thrust * 0.25)
		if (thrust < -0.25)	trails_handler.RecordTrailsReverse()
	}

	/*!
		Weaponry
		------------------------
	*/

	function	Shoot()
	{
		foreach(_cannon in cannon_handler)
		{
			_cannon.linear_velocity = linear_velocity
			_cannon.Shoot()
		}
	}

	/*!
		...
		------------------------
	*/

	function	SliderSetLinearDamping(_sprite, _value)
	{	base.SetLinearDamping(_value)	}
	function	SliderSetMaxThrust(_sprite, _value)
	{	max_thrust = _value	}
	function	SliderSetMaxAngularSpeed(_sprite, _value)
	{	max_angular_speed = _value	}

	function	FetchShipSettings(_gear = 0)
	{
		if (ship_name in ship_settings_table)
		{
			local	_gear_settings = (ship_settings_table[ship_name]).gears[_gear]
			base.SetLinearDamping(_gear_settings.damping)
			max_thrust = _gear_settings.max_thrust
			max_angular_speed =	_gear_settings.max_angular_speed
			max_speed = _gear_settings.max_speed
			current_gear = _gear
		}

		if (physic_settings_slider != 0)
		{
			physic_settings_slider[0].CallCallback(linear_damping)
			physic_settings_slider[1].CallCallback(max_thrust)
			physic_settings_slider[2].CallCallback(max_angular_speed)
		}
		
	}

	function	RenderUser(scene)
	{
		if ("RenderUser" in base)	base.RenderUser(scene)

		trails_handler.RenderTrails()

		foreach(_cannon in cannon_handler)
			_cannon.RenderUser()

		local	ship_position = ItemGetWorldPosition(body)
		if (!SceneGetScriptInstance(g_scene).hidden_ui) 
			RendererDrawLine(g_render, ship_position, ship_position + linear_velocity)
	}

	/*!
		@short	OnSetup
		Called when the item is about to be setup.
	*/
	function	OnSetup(item)
	{
		if ("OnSetup" in base)	base.OnSetup(item)

		thrust					=	0.0

		banking_item = ItemGetChild(item, "ship_banking")

		side_force = clone(g_zero_vector)
		
		base.SetLinearDamping(0.5)
		base.SetAngularDamping(1.0)

		orientation = ItemGetRotation(item)
		target_orientation = clone(orientation)
		target_direction = clone(front)

		//	Physics Settings Control UI
		physic_settings_slider = []
		local	top_window = g_WindowsManager.CreateVerticalSizer(0, 1000)
		top_window.SetParent(SceneGetScriptInstance(g_scene).master_ui_sprite)	
		top_window.SetPos(Vector(180, 8, 0))

		physic_settings_slider.append(g_WindowsManager.CreateSliderButton(top_window, tr("Inertie"), 0.0, 1.0, 0.05, linear_damping, this, "SliderSetLinearDamping"))
		physic_settings_slider.append(g_WindowsManager.CreateSliderButton(top_window, tr("Poussée"), 0.0, 100.0, 5.0, max_thrust, this, "SliderSetMaxThrust"))
		physic_settings_slider.append(g_WindowsManager.CreateSliderButton(top_window, tr("Rotation"), 0.0, 90.0, 0.1, max_angular_speed, this, "SliderSetMaxAngularSpeed"))

		//	Reactor's trails
		trails_handler = ShipTrails(banking_item)

		//	Cannons
		cannon_handler = []
		foreach(_item in ItemGetChildList(banking_item))
			if (ItemGetName(_item) == "cannon")
				cannon_handler.append(ShipCannon(_item))

		//	Audio
		audio_handler	 = ShipAudio()

		//	Register the "render user" callback of the ship's class.
		SceneGetScriptInstance(g_scene).render_user_callback.append(this)

		FetchShipSettings(0)
	}
}
