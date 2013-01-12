/*
	File: scripts/utils/trails.nut
	Author: P. Blanche - F. Gutherz
*/

/*!
	@short	Trails
	@author	P. Blanche - F. Gutherz
*/
class	Trails
{

	item					=	0
	point_list				=	0
	max_points				=	50
	base_color				=	0
	record_clock			=	0

	constructor(_item, _color = Vector(1,1,1,1))
	{
		item = _item
		point_list = []
		base_color = _color
		record_clock = g_clock
	}

	function	RecordPoint()
	{
		if ((g_clock - record_clock) > SecToTick(Sec(0.1)))
		{
			local	_pos = ItemGetWorldPosition(item)
			point_list.append(_pos)
			if (point_list.len() > max_points)	point_list.remove(0)
			record_clock = g_clock
		}
	}

	function	RenderUser(scene)
	{
		if (point_list.len() > 0)
		{
			local	_fade = 0.0, _step = 1.0 / (max_points.tofloat())
//			_fade -= (point_list.len() * _step)
			local	_prev_point = point_list[0]
			foreach(_point in point_list)
			{
				RendererDrawLineColored(g_render, _prev_point, _point, base_color.Scale(_fade))
				_fade = Min(1.0, _fade + _step)
				_prev_point = _point
			}
		}
		
	}

}
