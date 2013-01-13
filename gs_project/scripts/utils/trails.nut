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

	half_width				=	0.25

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
			local _pos = ItemGetWorldPosition(item)
			point_list.append({ p = _pos up = ItemGetRotationMatrix(item).GetRow(1) })
			if (point_list.len() > max_points)	point_list.remove(0)
			record_clock = g_clock
		}
	}

	function	AppendSection(t, sections, prev_p, p, up)
	{
		local v = (p - prev_p).Normalize()
		local u = v.Cross(up).Normalize(half_width + sin(t * 4.0) * 0.18)	// smoke like, pretty cool
//		local u = v.Cross(up).Normalize(half_width)	// beam like

		// TODO add UV here
		sections.append({p = p - u})
		sections.append({p = p + u})
	}

	function	RenderUser(scene)
	{
		if	(point_list.len() < 2)
			return

		// Setup trail quad sections.
		local sections = []
		for (local n = 1; n < point_list.len(); ++n)
			AppendSection(n.tofloat() / point_list.len(), sections, point_list[n - 1].p, point_list[n].p, point_list[n].up)
		AppendSection(1.0, sections, point_list[point_list.len() - 1].p, ItemGetWorldPosition(item), ItemGetRotationMatrix(item).GetRow(1))

		// Draw quads.
		local section_count = sections.len() / 2
		local alpha = 1.0, step = 1.0 / section_count

		for (local n = 0; n < (sections.len() - 2); n += 2)
		{
			local color_a = Vector(0.0, 0.7, 1, 1.0 - alpha)
			alpha = Max(0.0, alpha - step)
			local color_b = Vector(0.0, 0.7, 1, 1.0 - alpha)

			RendererDrawTriangle(g_render, sections[n].p, sections[n + 1].p, sections[n + 3].p, color_a, color_a, color_b, MaterialBlendAdd, MaterialRenderDoubleSided | MaterialRenderNoDepthWrite)
			RendererDrawTriangle(g_render, sections[n].p, sections[n + 3].p, sections[n + 2].p, color_a, color_b, color_b, MaterialBlendAdd, MaterialRenderDoubleSided | MaterialRenderNoDepthWrite)
		}
	}
}
