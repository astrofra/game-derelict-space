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

	constructor(_pos = Vector(), _dir = Vector(), _speed = Mtrs(1.0))
	{
		position = _pos
		direction = _dir
		speed = _speed
	}

	function	Update()
	{
		position += direction.Scale(speed)
	}

	function	Render()
	{
		DrawQuadInXZPlane(position, direction, Mtr(0.5))
	}
}

/*!
	@short	ShipCannon
	@author	P. Blanche - F. Gutherz
*/
class	ShipCannon
{
	//	Public members
	frequency		=	10.0 		//	In Hz
	damage			=	1.0			//	Damage caused on each bullet impact
	range			=	Mtr(100.0)	//	Past this range, the bullet fades out.
	energy_cost		=	10.0		//	How much energy is necessary for 1 bullet
	spread_angle	=	Deg(30.0)	//	Max angular range of the cannon

	item			=	0
	position		=	0
	direction		=	0

	//	Private
	bullet_list		=	0
	shoot_timeout	=	0

	constructor(_cannon_item)
	{
		item = _cannon_item
		bullet_list = []
		position = Vector()
		direction = Vector()
		shoot_timeout = g_clock
	}

	function	Shoot()
	{
		if (g_clock - shoot_timeout < SecToTick(Sec(1.0 / frequency)))
			return

		print("ShipCannon::Shoot()")
		shoot_timeout = g_clock
		bullet_list.append(Bullet(position, direction))
	}

	function	Update()
	{
		position = ItemGetWorldPosition(item)
		direction = ItemGetMatrix(item).GetFront()

		foreach(bullet in bullet_list)
			bullet.Update()
	}

	function	RenderUser()
	{
		foreach(bullet in bullet_list)
			bullet.Render()
	}
}
