/*
	File: scripts/ship.nut
	Author: P. Blanche - F. Gutherz
*/

Include("scripts/utils/physic_item_orbiting.nut")
Include("scripts/utils/trails_sprite.nut")

/*!
	@short	Ship
	@author	P. Blanche - F. Gutherz
*/
class	Ship	extends	PhysicOrbitingItem
{


	max_speed				=	100.0	//	Unused, so far
	max_thrust				=	20.0
	max_angular_speed		=	1.2

	thrust					=	10.0
	vector_front			=	0
	orientation				=	0
	target_orientation		=	0
	target_direction		=	0
	strafe_force			=	0
	strafe_timeout			=	0

	current_gear			=	0

	side_force				=	0
	banking					=	0.0
	target_banking			=	0.0

	banking_item			=	0
	trails					=	0
	trails_reverse			=	0

	samples					=	0
	channels				=	0

	physic_settings_slider	=	0

	/*!
		@short	OnUpdate
		Called during the scene update, each frame.
	*/
	function	OnUpdate(item)
	{
		if ("OnUpdate" in base)	base.OnUpdate(item)

		UpdateBanking()
		
		orientation = ItemGetRotation(item)
		if (thrust > 0.0)
			thrust	= Max(thrust -= g_dt_frame * 15.0, 0.0)
		else
		if (thrust < 0.0)
			thrust	= Min(thrust += g_dt_frame * 15.0, 0.0)
		

		UpdateLabel(item)

		UpdateAudio()
	}

	function	RecordTrails()
	{
		foreach(_trail in trails)
			_trail.RecordPoint()
	}
	
	function	RecordTrailsReverse()
	{
		foreach(_trail in trails_reverse)
			_trail.RecordPoint()
	}

	function	OnDelete(item)
	{
		MixerChannelStop(g_mixer,  channels["ship_reactor"])
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

	function	UpdateAudio()
	{
		local	_speed = RangeAdjust(fabs(thrust), 0.0, max_thrust, 0.0, 1.0)
		local	_gain = Clamp(_speed, 0.1, 1.0)
		local	_pitch = Clamp(RangeAdjust(_speed, 0.0, 1.0, 0.8, 1.2), 0.8, 1.2)
		MixerChannelSetGain(g_mixer, channels["ship_reactor"], _gain)
		MixerChannelSetPitch(g_mixer, channels["ship_reactor"], _pitch)
		
	}

	function	SfxSetOrientationTarget()
	{
		local	_chan = MixerSoundStart(g_mixer, samples["gui_up_down"])
		MixerChannelSetGain(g_mixer, _chan, 0.25)
	}

	function	OnPhysicStep(item, dt)
	{
		if ("OnPhysicStep" in base)	base.OnPhysicStep(item, dt)

		local	body_matrix = ItemGetMatrix(item)
		vector_front = body_matrix.GetFront()

		ItemApplyLinearForce(item, vector_front.Scale(mass * thrust))

		//	Align the ship to the desired orientation
		//	If the reactor are ON
		local	should_rotate = false
		if (fabs(thrust) > 0.0)	should_rotate = true

		if (should_rotate)
		{
			local	_torque
			_torque = target_orientation - orientation
			if (_torque.y > Deg(180.0) || _torque.y < Deg(-180.0))
				_torque = (orientation - target_orientation)

			_torque.y = Clamp(_torque.y, Deg(-max_angular_speed), Deg(max_angular_speed))

			local	_acc_feedback = RangeAdjust(Abs(_torque.y), Deg(max_angular_speed * 1.5), Deg(0.0), 0.0, 1.0)
			_acc_feedback = Pow(Clamp(_acc_feedback, 0.0, 1.0), 4.0)
			_torque -= ItemGetAngularVelocity(item).Scale(_acc_feedback)

			//	Velocity contribution
			local	_vel_factor = linear_velocity.Len()
			_vel_factor = RangeAdjust(_vel_factor, 1.0, 10.0, 0.0, 1.0)
			_vel_factor = Clamp(_vel_factor, 0.0, 1.0)

			ItemApplyTorque(item, _torque.Scale(100.0 * mass * _vel_factor))
		}

		//	Banking
		local	_dot = 1.0 - vector_front.Normalize().Dot(linear_velocity.Normalize())
		local	_cross = vector_front.Normalize().Cross(linear_velocity.Normalize())
		if (_cross.y > 0.0) _dot *= -1.0

		side_force = body_matrix.GetLeft().Scale(_dot * 50.0)
		target_banking = _dot * linear_velocity.Len()

		//	Straffing
		if (strafe_force.Len2() > 0.0)
		{
			strafe_force += strafe_force.Reverse().Scale(30.0 * g_dt_frame)
			ItemApplyLinearForce(item, strafe_force.Scale(mass))
		}
		

		//	Camera Update
		SceneGetScriptInstance(g_scene).camera_handler.Update(SceneGetScriptInstance(g_scene).player_item)
	}

	function	StrafeLeft()
	{
		if (g_clock - strafe_timeout < SecToTick(Sec(0.25)))
			return

//		if (strafe_force.Len2() > 0.0)
//			return

		strafe_force = left.Scale(10.0 * max_thrust)
		local	_strafe_chan = MixerSoundStart(g_mixer, samples["ship_strafe"])
		MixerChannelSetPitch(g_mixer, _strafe_chan, Rand(0.975,1.025))
		strafe_timeout = g_clock
	}

	function	StrafeRight()
	{
		if (g_clock - strafe_timeout < SecToTick(Sec(0.25)))
			return

//		if (strafe_force.Len2() > 0.0)
//			return

		strafe_force = left.Reverse().Scale(10.0 * max_thrust)
		local	_strafe_chan = MixerSoundStart(g_mixer, samples["ship_strafe"])
		MixerChannelSetPitch(g_mixer, _strafe_chan, Rand(0.975,1.025))
		strafe_timeout = g_clock
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
		thrust	= Min(thrust += g_dt_frame * 60.0, max_thrust)
		if (thrust > 0.1)	RecordTrails()
	}

	function	SetThrustDown()
	{
		thrust	= Max(thrust -= g_dt_frame * 60.0 * 0.5, -max_thrust * 0.25)
		if (thrust < -0.25)	RecordTrailsReverse()
	}


	function	RenderUser(scene)
	{
		if ("RenderUser" in base)	base.RenderUser(scene)

		foreach(_trail in trails)
			_trail.RenderUser(scene)

		foreach(_trail in trails_reverse)
			_trail.RenderUser(scene)

		local	ship_position = ItemGetWorldPosition(body)
		if (!SceneGetScriptInstance(g_scene).hidden_ui) 
			RendererDrawLine(g_render, ship_position, ship_position + linear_velocity)
//		RendererDrawLine(g_render, ship_position, ship_position + side_force)

//		foreach(_F in attraction_forces_list)
//			RendererDrawLineColored(g_render, position, position + _F, Vector(0.1,0.2,1.0))
	}

	function	SliderSetLinearDamping(_sprite, _value)
	{	base.SetLinearDamping(_value)	}
	function	SliderSetMaxThrust(_sprite, _value)
	{	max_thrust = _value	}
	function	SliderSetMaxAngularSpeed(_sprite, _value)
	{	max_angular_speed = _value	}

	function	LoadSample(_filename)
	{
		local	_fname = "sfx/" + _filename + ".wav"
		if (FileExists(_fname))
			samples.rawset(_filename, ResourceFactoryLoadSound(g_factory, _fname))
	}

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

	/*!
		@short	OnSetup
		Called when the item is about to be setup.
	*/
	function	OnSetup(item)
	{
		if ("OnSetup" in base)	base.OnSetup(item)

		thrust					=	0.0

		banking_item = ItemGetChild(item, "ship_banking")

		vector_front = clone(g_zero_vector)
		side_force = clone(g_zero_vector)
		
		base.SetLinearDamping(0.5)
		base.SetAngularDamping(1.0)

		orientation = ItemGetRotation(item)
		target_orientation = clone(orientation)
		target_direction = clone(vector_front)

		strafe_force = Vector(0,0,0,0)
		strafe_timeout = g_clock

		//	Physics Settings Control UI
		physic_settings_slider = []
		local	top_window = g_WindowsManager.CreateVerticalSizer(0, 1000)
		top_window.SetParent(SceneGetScriptInstance(g_scene).master_ui_sprite)	
		top_window.SetPos(Vector(180, 8, 0))

		physic_settings_slider.append(g_WindowsManager.CreateSliderButton(top_window, tr("Inertie"), 0.0, 1.0, 0.05, linear_damping, this, "SliderSetLinearDamping"))
		physic_settings_slider.append(g_WindowsManager.CreateSliderButton(top_window, tr("Poussée"), 0.0, 100.0, 5.0, max_thrust, this, "SliderSetMaxThrust"))
		physic_settings_slider.append(g_WindowsManager.CreateSliderButton(top_window, tr("Rotation"), 0.0, 90.0, 0.1, max_angular_speed, this, "SliderSetMaxAngularSpeed"))

		//	Reactor's trails
		trails = []
		trails_reverse = []
		local	_list = ItemGetChildList(banking_item)
		foreach(_child in _list)
			if (ItemGetName(_child) == "trail")	trails.append(TrailsSprite(_child, g_vector_orange, MaterialBlendNone))
		foreach(_child in _list)
			if (ItemGetName(_child) == "trail_reverse")	trails_reverse.append(TrailsSprite(_child, g_vector_orange, MaterialBlendNone))

		SceneGetScriptInstance(g_scene).render_user_callback.append(this)

		samples = {}
		channels = {}

		LoadSample("ship_reactor")
		channels.rawset("ship_reactor", MixerSoundStart(g_mixer, samples["ship_reactor"]))
		MixerChannelSetLoopMode(g_mixer, channels["ship_reactor"], LoopRepeat)
		LoadSample("ship_strafe")
		LoadSample("gui_up_down")

		FetchShipSettings(0)

//		SetOrbitOnItem(SceneFindItem(g_scene, "asteroid_s3_0"))
	}
}
