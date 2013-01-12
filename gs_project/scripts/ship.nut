/*
	File: scripts/ship.nut
	Author: P. Blanche - F. Gutherz
*/

Include("scripts/utils/physic_item_xz_plane.nut")

/*!
	@short	Ship
	@author	P. Blanche - F. Gutherz
*/
class	Ship	extends	PhysicItemXZPlane
{

	thrust					=	10.0
	vector_front			=	0
	orientation				=	0
	target_orientation		=	0
	target_direction		=	0

	/*!
		@short	OnUpdate
		Called during the scene update, each frame.
	*/
	function	OnUpdate(item)
	{
		if ("OnUpdate" in base)	base.OnUpdate(item)
		orientation = ItemGetRotation(item)
	}

	function	OnPhysicStep(item, dt)
	{
		base.OnPhysicStep(item, dt)

		local	body_matrix = ItemGetMatrix(item)
		vector_front = body_matrix.GetFront()

		ItemApplyLinearForce(item, vector_front.Scale(mass * thrust))

		local	_torque

		_torque = target_orientation - orientation
		if (_torque.y > Deg(180.0) || _torque.y < Deg(-180.0))
			_torque = orientation - target_orientation

		_torque.y = Clamp(_torque.y, Deg(-45.0), Deg(45.0))

		local	_acc_feedback = RangeAdjust(Abs(_torque.y), Deg(45.0), Deg(0.0), 0.0, 1.0)
		_acc_feedback = Pow(Clamp(_acc_feedback, 0.0, 1.0), 4.0)	
		_torque -= ItemGetAngularVelocity(item).Scale(_acc_feedback)

		ItemApplyTorque(item, _torque.Scale(100.0 * mass))

		//	Camera Update
		SceneGetScriptInstance(g_scene).camera_handler.Update(SceneGetScriptInstance(g_scene).player_item)
	}

	/*!
		@short	OnSetup
		Called when the item is about to be setup.
	*/
	function	OnSetup(item)
	{
		base.OnSetup(item)

		vector_front = g_zero_vector
		
		base.SetLinearDamping(0.5)
		base.SetAngularDamping(1.0)

		orientation = ItemGetRotation(item)
		target_orientation = clone(orientation)
		target_direction = clone(vector_front)
	}
}
