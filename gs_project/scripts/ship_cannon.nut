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
	linear_acceleration	=	0
	linear_velocity =	0
	speed			=	Mtrs(100.0)

	prev_position	=	0
	distance		=	0

	constructor(_pos = Vector(), _dir = Vector(), _accel = Vector(), _vel = Vector())
	{
		position = _pos
		prev_position = clone(position)
		direction = _dir
		direction.y = 0.0
		direction = direction.Normalize()
		linear_acceleration = _accel
		linear_velocity = _vel
	}

	function	Update()
	{
		position += (direction.Scale(speed * g_dt_frame) + linear_velocity.Scale(g_dt_frame)) // direction.Scale(speed * g_dt_frame)
		distance += position.Dist(prev_position)
		prev_position = clone(position)
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
	frequency		=	5.0 		//	In Hz
	damage			=	1.0			//	Damage caused on each bullet impact
	range			=	Mtr(1000.0)	//	Past this range, the bullet fades out.
	energy_cost		=	10.0		//	How much energy is necessary for 1 bullet
	spread_angle	=	Deg(30.0)	//	Max angular range of the cannon

	bullet_speed	=	Mtrs(50.0)
	linear_velocity	=	0
	linear_acceleration	=	0

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
		linear_velocity =	Vector()
		linear_acceleration = Vector()
		shoot_timeout = g_clock
	}

	function	Shoot(_ship_direction = 0)
	{
		if (g_clock - shoot_timeout < SecToTick(Sec(1.0 / frequency)))
			return

		shoot_timeout = g_clock
		bullet_list.append(Bullet(position, direction, linear_acceleration, linear_velocity))
	}

	function	Update()
	{
		position = ItemGetWorldPosition(item)
		direction = ItemGetMatrix(item).GetFront()

		foreach(idx, bullet in bullet_list)
		{
			bullet.Update()
			if (bullet.distance > range)
				bullet_list.remove(idx)
		}
	}

	function	RenderUser()
	{
		RendererDrawLine(g_render, position, position + direction.Scale(5.0))
		foreach(bullet in bullet_list)
			bullet.Render()
	}
}
