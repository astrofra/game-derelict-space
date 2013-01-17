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

		//	F(A->B) = -G * ((m1 * m2) / (d^2)) * Vector(A,B) 
		local	F = g_zero_vector
		local	player_mass = ItemGetMass(player_item)
		//F = 
		
	}

	function	OnSetup(item)
	{
		if ("OnSetup" in base)	base.OnSetup(item)
		player_item = SceneFindItem(scene, "ship")
	}

}
