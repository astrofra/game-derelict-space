/*
	File: scripts/ship_trails.nut
	Author: P. Blanche - F. Gutherz
*/

Include("scripts/utils/trails_sprite.nut")

/*!
	@short	ShipTrails
	@author	P. Blanche - F. Gutherz
*/
class	ShipTrails
{
	trails					=	0
	trails_reverse			=	0
	scene					=	0

	function	RenderTrails()
	{
		foreach(_trail in trails)
			_trail.RenderUser(scene)

		foreach(_trail in trails_reverse)
			_trail.RenderUser(scene)
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

	/*!
		@short	constructor
	*/
	constructor(_root_item, _color = g_vector_orange)
	{
		//	Reactor's trails
		scene = ItemGetScene(_root_item)
		trails = []
		trails_reverse = []
		local	_list = ItemGetChildList(_root_item)
		foreach(_child in _list)
			if (ItemGetName(_child) == "trail")	trails.append(TrailsSprite(_child, _color, MaterialBlendNone))
		foreach(_child in _list)
			if (ItemGetName(_child) == "trail_reverse")	trails_reverse.append(TrailsSprite(_child, _color, MaterialBlendNone))
	}
}
