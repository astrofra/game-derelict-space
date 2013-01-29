/*
	File: scripts/ship.nut
	Author: P. Blanche - F. Gutherz
*/

Include("scripts/utils/physic_item_xz_plane.nut")

/*!
	@short	Asteroid
	@author	P. Blanche - F. Gutherz
*/
class	Asteroid	extends	PhysicItemXZPlane
{
	player_item			=	0

	function	OnUpdate(item)
	{
		if ("OnUpdate" in base)	base.OnUpdate(item)

		//	F(A->B) = -G * ((mA * mB) / (d^2)) * Vector(A,B) 
		local	F = g_zero_vector
		local	player_mass = ItemGetMass(player_item)
		local	vect_ship_to_this =  position - ItemGetPosition(player_item)
		local	dist_to_ship_sqr =	vect_ship_to_this.Len2()

		if (dist_to_ship_sqr > 0.0)
		{
g_gravitational_constant = 0.001
			local	F = vect_ship_to_this.Normalize().Scale(g_gravitational_constant * ((player_mass * mass) / dist_to_ship_sqr))
//			print("F = " + F.Len())
			ItemGetScriptInstance(player_item).ApplyAttraction(F)
		}
		
	}

	function	OnSetup(item)
	{
		if ("OnSetup" in base)	base.OnSetup(item)
		player_item = SceneFindItem(g_scene, "ship")
	}
}
