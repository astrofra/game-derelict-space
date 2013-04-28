/*
	File: scripts/ship_trails.nut
	Author: P. Blanche - F. Gutherz
*/

/*!
	@short	ShipTrails
	@author	P. Blanche - F. Gutherz
*/
class	ShipTrails
{
	trails					=	0
	trails_reverse			=	0



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

	/*!
		@short	constructor
	*/
	constructor()
	{
		//	Reactor's trails
		trails = []
		trails_reverse = []
		local	_list = ItemGetChildList(banking_item)
		foreach(_child in _list)
			if (ItemGetName(_child) == "trail")	trails.append(TrailsSprite(_child, g_vector_orange, MaterialBlendNone))
		foreach(_child in _list)
			if (ItemGetName(_child) == "trail_reverse")	trails_reverse.append(TrailsSprite(_child, g_vector_orange, MaterialBlendNone))
	}
}
