/*
	File: scripts/utils/physic_item_xz_plane.nut
	Author: P. Blanche - F. Gutherz
*/

/*!
	@short	PhysicItemZPlane
	@author	P. Blanche - F. Gutherz
*/
class	PhysicItemXZPlane
{
	body				=	0
	mass				=	0
	linear_damping		=	0.0
	angular_damping		=	0.0
	linear_velocity		=	0
	angular_velocity	=	0

	function	OnSetup(item)
	{
		body = item
		mass = ItemGetMass(body)
		ItemPhysicSetLinearFactor(item, Vector(1,0,1))
		ItemPhysicSetAngularFactor(item, Vector(0,1,0))
		linear_velocity = g_zero_vector
		angular_velocity = g_zero_vector
	}

	function	OnPhysicStep(item, dt)
	{
		linear_velocity = ItemGetLinearVelocity(item)
		angular_velocity = ItemGetAngularVelocity(item)

		if (linear_damping > 0.0)
		{
			local	_scale = Clamp(linear_damping, 0.0, 1.0) * -1.0 * mass
			ItemApplyLinearForce(item, linear_velocity.Scale(_scale))
		}

		if (angular_damping > 0.0)
		{
			local	_scale = Clamp(angular_damping, 0.0, 1.0) * -1.0 * mass
			ItemApplyTorque(item, angular_velocity.Scale(_scale))
		}		
	}

	function	SetAngularDamping(_value)
	{
		angular_damping = _value
	}

	function	SetLinearDamping(_value)
	{
		linear_damping = _value
	}

}
