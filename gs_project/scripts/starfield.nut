/*
	File: scripts/starfield.nut
	Author: P. Blanche - F. Gutherz
*/

/*!
	@short	Starfield
	@author	P. Blanche - F. Gutherz
*/
class	Starfield
{
	size 					= 250
	step 					= 20
	rand_table				= 0

	function	Update(position)
	{
		local offset = clone(position)
		offset.x = ((offset.x / step).tointeger() * step).tofloat()
		offset.z = ((offset.z / step).tointeger() * step).tofloat()

		local	x,z
		for(x = -size; x < size; x+=step)
			for(z = -size; z < size; z+=step)
			{
				local	noise = size + x + z + offset.x + offset.z
				noise = 0 //rand_table[Mod(noise, 256)]
				local	_star_pos = Vector(x + noise * 0.2, -noise * 0.1 ,z + noise * 0.2) + offset
				RendererDrawLine(g_render, _star_pos, _star_pos + Vector(0.1,0,0.1))		
			}	
	}

	function	SetSize(_size)
	{
		_size = Max(_size, 50)
		_size = ((_size * step).tointeger() / step).tointeger()
		size = _size
	}

	constructor()
	{
		rand_table = []
		local n
		for(n = 0; n < 256; n++)
			rand_table.append(Irand(0,256))	

	}

}
