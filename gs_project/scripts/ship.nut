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

		if (0)
		{
			_torque = target_orientation - orientation
			_torque -= ItemGetAngularVelocity(item)

			print("ty = " + RadianToDegree(target_orientation.y))
			print("y  = " + RadianToDegree(orientation.y))
		}
		else
		{
			target_quaternion = QuaternionLookAt(target_direction)
			local	current_quaternion = QuaternionFromMatrix3(ItemGetRotationMatrix(item))
			local	lerp_quaternion = current_quaternion.Slerp(0.5, target_quaternion)
			_torque = Vector(0,lerp_quaternion.w,0)
		}

		ItemApplyTorque(item, _torque.Scale(50.0 * mass))

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
