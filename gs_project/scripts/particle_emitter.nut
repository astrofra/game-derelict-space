/*
	File: scripts/particle_emitter.nut
	Author: P. Blanche - F. Gutherz
*/

class	Particle
{
	position		=	0
	size			=	0
	color			=	0
	deflation_rate 	= 1.0
	direction		=	0
	died			=	false

	constructor(_pos = Vector(), _size = Mtr(1.0), _color = Vector(1,1,1,1), _deflation_rate = 1.0)
	{
		position = _pos
		size = _size
		color = clone(_color)
		deflation_rate = _deflation_rate

		direction = Vector()
		direction.x = Rand(-1.0, 1.0)
		direction.z = Rand(-1.0, 1.0)
		direction = direction.Normalize()
	}

	function	Update()
	{
		size = Max(0.0, size - (g_dt_frame * deflation_rate))
		color.w = Max(0.0, size - (color.w * deflation_rate))

		if (size <= 0.01)
			died = true
	}

	function	Render()
	{
		DrawQuadInXZPlane(position, direction, size, color)
	}
}

/*!
	@short	ParticleEmitter
	@author	P. Blanche - F. Gutherz
*/
class	ParticleEmitter
{
	position			=	0
	particle_list		=	0

	constructor()
	{
		position = Vector()
		particle_list = []
	}

	function	Emit(_pos = -1)
	{
		if (_pos != -1)
			position = _pos

		particle_list.append(Particle(position, Rand(1.0, 2.0)))
	}

	function	Update()
	{
		foreach(idx, particle in particle_list)
		{
			particle.Update()
			if ((particle.died))
				particle_list.remove(idx)
		}
	}

	function	RenderUser()
	{
		foreach(particle in particle_list)
			particle.Render()
	}
}
