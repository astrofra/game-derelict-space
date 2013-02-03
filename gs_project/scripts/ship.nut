/*
	File: scripts/ship.nut
	Author: P. Blanche - F. Gutherz
*/

Include("scripts/utils/physic_item_xz_plane.nut")
Include("scripts/utils/trails.nut")

/*!
	@short	Ship
	@author	P. Blanche - F. Gutherz
*/
class	Ship	extends	PhysicItemXZPlane
{


	max_speed				=	100.0
	max_thrust				=	10.0
	max_angular_speed		=	90.0

	thrust					=	10.0
	vector_front			=	0
	orientation				=	0
	target_orientation		=	0
	target_direction		=	0

	trails					=	0

	/*!
		@short	OnUpdate
		Called during the scene update, each frame.
	*/
	function	OnUpdate(item)
	{
		if ("OnUpdate" in base)	base.OnUpdate(item)

		orientation = ItemGetRotation(item)
		thrust	= Max(thrust -= g_dt_frame * 15.0, 0.0)
		foreach(_trail in trails)
			_trail.RecordPoint()

		UpdateLabel(item)
	}

	function	UpdateLabel(item)
	{
		local	_script = ItemGetScriptInstanceFromClass(item, "ItemLabel3D")
		if ("label" in _script)
			_script.label = "Speed = " + linear_velocity.Len().tointeger().tostring() + " m/s\nRot = " + RadianToDegree(orientation.y).tointeger().tostring() + " deg."
	}

	function	OnPhysicStep(item, dt)
	{
		if ("OnPhysicStep" in base)	base.OnPhysicStep(item, dt)

		local	body_matrix = ItemGetMatrix(item)
		vector_front = body_matrix.GetFront()

		ItemApplyLinearForce(item, vector_front.Scale(mass * thrust))

		local	_torque

		_torque = target_orientation - orientation
		if (_torque.y > Deg(180.0) || _torque.y < Deg(-180.0))
			_torque = (orientation - target_orientation)

		_torque.y = Clamp(_torque.y, Deg(-max_angular_speed), Deg(max_angular_speed))

		local	_acc_feedback = RangeAdjust(Abs(_torque.y), Deg(max_angular_speed * 1.5), Deg(0.0), 0.0, 1.0)
		_acc_feedback = Pow(Clamp(_acc_feedback, 0.0, 1.0), 4.0)	
		_torque -= ItemGetAngularVelocity(item).Scale(_acc_feedback)

		ItemApplyTorque(item, _torque.Scale(100.0 * mass))

		//	Camera Update
		//SceneGetScriptInstance(g_scene).camera_handler.Update(SceneGetScriptInstance(g_scene).player_item)
	}

	function	SetOrientation(_euler)
	{
		target_orientation = _euler
	}

	function	SetThrustUp()
	{
		thrust	= Min(thrust += g_dt_frame * 60.0, max_thrust)
	}

	function	RenderUser(scene)
	{
		foreach(_trail in trails)
			_trail.RenderUser(scene)

		local	ship_position = ItemGetWorldPosition(body)
		RendererDrawLine(g_render, ship_position, ship_position + linear_velocity)

		foreach(_F in attraction_forces_list)
			RendererDrawLineColored(g_render, position, position + _F, Vector(0.1,0.2,1.0))
	}

	function	SliderSetLinearDamping(_sprite, _value)
	{	base.SetLinearDamping(_value)	}
	function	SliderSetMaxThrust(_sprite, _value)
	{	max_thrust = _value	}
	function	SliderSetMaxAngularSpeed(_sprite, _value)
	{	max_angular_speed = _value	}

	/*!
		@short	OnSetup
		Called when the item is about to be setup.
	*/
	function	OnSetup(item)
	{
		base.OnSetup(item)

		vector_front = g_zero_vector
		
		base.SetLinearDamping(0.1)
		base.SetAngularDamping(1.0)

		orientation = ItemGetRotation(item)
		target_orientation = clone(orientation)
		target_direction = clone(vector_front)

		//	Physics Settings Control UI
		local	top_window = g_WindowsManager.CreateVerticalSizer(0, 1000)		
		top_window.SetPos(Vector(256, 8, 0))

		g_WindowsManager.CreateSliderButton(top_window, tr("Inertie"), 0.0, 1.0, 0.05, linear_damping, this, "SliderSetLinearDamping")
		g_WindowsManager.CreateSliderButton(top_window, tr("Poussée"), 0.0, 100.0, 5.0, max_thrust, this, "SliderSetMaxThrust")
		g_WindowsManager.CreateSliderButton(top_window, tr("Rotation"), 0.0, 180.0, 1.0, max_angular_speed, this, "SliderSetMaxAngularSpeed")

		//	Reactor's trails
		trails = []
		local	_list = ItemGetChildList(item)
		foreach(_child in _list)
			if (ItemGetName(_child) == "trail")	trails.append(Trails(_child))

		SceneGetScriptInstance(g_scene).render_user_callback.append(this)
	}
}
