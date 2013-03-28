/*
	File: scripts/utils/trails_sprite.nut
	Author: P. Blanche - F. Gutherz
*/

/*!
	@short	TrailsSprite
	@author	P. Blanche - F. Gutherz
*/
class	TrailsSprite
{
	item					=	0
	parent_item				=	0
	point_list				=	0
	max_points				=	50
	record_clock			=	0
	emitter_timeout			=	0.0
	base_color				=	0
	base_blendmode			=	0

	constructor(_item, _color = Vector(1,1,1,1), _blendmode = MaterialBlendAlpha)
	{
		item = _item
		parent_item = ItemGetParent(ItemGetParent(item))
		point_list = []
		base_color = _color
		base_blendmode = _blendmode
	}

	function	RecordPoint()
	{
		emitter_timeout = (g_clock - record_clock) / SecToTick(Sec(0.01))
		if	(emitter_timeout <= 1.0)
			return

		record_clock = g_clock
		emitter_timeout = 0.0

		point_list.append({ p = ItemGetWorldPosition(item), 
							y = ItemGetRotationMatrix(item).GetRow(1), 
							a = ItemGetScriptInstance(parent_item).linear_acceleration.Reverse(),
							s = 1.0,
							age = 1.0
							})
		if	(point_list.len() > max_points)
			point_list.remove(0)
	}

	
	function	RenderUser(scene)
	{
		if	(point_list.len() < 2)
			return

		foreach(idx, _point in point_list)
		{
			//RendererDrawCrossColored(g_render, _point.p, base_color)
			local	_age = Pow(_point.age, 0.25)
			local	_scale = Pow(Clamp(_age, 0.01, 1.0), 4.0)
			_scale *= Pow(Clamp(RangeAdjust(_point.age, 1.0, 0.9, 0.0, 1.0), 0.0, 1.0), 2.0)
			DrawQuadInXZPlane(_point.p, _point.y * Vector(1,0,1), Mtr(1.0 * _scale), base_color.Scale(_age), base_blendmode)
			point_list[idx].p += (_point.a.Scale(g_dt_frame * g_dt_frame))
			point_list[idx].s = Max(0.0, _point.s - (g_dt_frame * 0.1))
			point_list[idx].age = Max(0.0, _point.age - g_dt_frame)
		}
	}

}
