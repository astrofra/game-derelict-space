/*
	File: scripts/ship_cannon.nut
	Author: P. Blanche - F. Gutherz
*/

/*!
	@short	Bullet
	@author	P. Blanche - F. Gutherz
*/
class	Bullet
{
	position		=	0
	direction		=	0
	speed			=	Mtrs(1.0)

	bullet_width	=	Mtr(0.35)
	bullet_height	=	Mtr(0.35)

	constructor(_pos = Vector(), _dir = Vector(), _speed = Mtrs(1.0))
	{
		position = _pos
		direction = _dir
		speed = _speed
	}

	function	Render()
	{
	}
}

/*!
	@short	ShipCannon
	@author	P. Blanche - F. Gutherz
*/
class	ShipCannon
{
	position		=	0
	direction		=	0

	frequency		=	60.0 		//	In Hz
	damage			=	1.0			//	Damage caused on each bullet impact
	range			=	Mtr(100.0)	//	Past this range, the bullet fades out.
	energy_cost		=	10.0		//	How much energy is necessary for 1 bullet
	spread_angle	=	Deg(30.0)	//	Max angular range of the cannon

	bullet_list		=	0

	//	Private
	shoot_timeout	=	0

	constructor()
	{
		bullet_list = []
		position = Vector()
		direction = Vector()
	}

	function	Shoot()
	{
		if (g_clock - shoot_timeout < SecToTick(Sec(1.0 / frequency)))
			return

		shoot_timeout = g_clock
		bullet_list.append(Bullet(position, direction))
	}

	function	Update()
	{
		foreach(bullet in bullet_list)
		{
			bullet.position += direction.Scale(speed)
		}
	}

	function	RenderUser()
	{
		foreach(bullet in bullet_list)
			DrawQuadInXZPlane(bullet.position, bullet.direction, Mtr(0.5))
	}
}
