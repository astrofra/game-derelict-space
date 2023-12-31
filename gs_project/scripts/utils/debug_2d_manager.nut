
/*!
	@short	debug 2D maanger
	@author	Movida Production
*/
class	Debug2dManager
{
	pattern_draw = 0

//***************************************************************************************************
	
	function RenderLine(parm)
	{
		RendererDrawLineColored(g_render, parm.pos_a, parm.pos_b, parm.color)	
	}

	function RenderCross(parm)
	{
		RendererDrawCrossColored(g_render, parm.pos_a, parm.color)	
	}

//***************************************************************************************************
	
	function OnRenderUser(scene)
	{	
		RendererSetIdentityWorldMatrix(g_render)
		
		foreach(pattern in pattern_draw)
		{
			this[pattern.callback](pattern.parm)
		}

		pattern_draw.clear()
	}

//***************************************************************************************************

	function DrawLine(a, b, _color=Vector(1,1,1))
	{
		pattern_draw.append({callback="RenderLine", parm={pos_a=a, pos_b=b, color=_color}})
	}

	function DrawCross(a, _color=Vector(1,1,1))
	{
		pattern_draw.append({callback="RenderCross", parm={pos_a=a, color=_color}})
	}

//***************************************************************************************************
	
	constructor()
	{
		pattern_draw = []
	}
}
