/*
	File: scripts/settings_table_ship.nut
	Author: P. Blanche - F. Gutherz
*/

ship_settings_table <-	{
//	Arrow:nerveux tres maniable
	arrow	=	{	name = tr("Arrow"), description = tr("Nerveux et très maniable."),
					gears = [
						{ damping = 0.9,	max_thrust = 15.0,	max_angular_speed = 10.0,	max_speed = 20.0 }
						{ damping = 0.9,	max_thrust = 50.0,	max_angular_speed = 10.0,	max_speed = 85.0 }
						{ damping = 0.9,	max_thrust = 75.0,	max_angular_speed = 10.0,	max_speed = 85.0 }
					]
				}

//	Orbiter:puissant, maniable, bonnes vitesses de base
	orbiter	=	{	name = tr("Orbiter"), description = tr("Puissant, maniable, bonnes vitesses de base."),
					gears = [
						{ damping = 1.0,	max_thrust = 35.0,	max_angular_speed = 5.0,	max_speed = 35.0}
						{ damping = 1.0,	max_thrust = 60.0,	max_angular_speed = 5.0,	max_speed = 60.0}
						{ damping = 1.0,	max_thrust = 70.0,	max_angular_speed = 5.0,	max_speed = 70.0}
					]
				}

//	Drifter: tres rapide,  tourne tres vite, mais dur a piloter
	drifter =	{	name = tr("Drifter"), description = tr("Très rapide,  tourne très vite, mais dur à piloter."),
					gears = [
						{ damping = 0.4,	max_thrust = 10.0,	max_angular_speed = 15.0,	max_speed = 25.0}
						{ damping = 0.4,	max_thrust = 25.0,	max_angular_speed = 15.0,	max_speed = 60.0}
						{ damping = 0.4,	max_thrust = 50.0,	max_angular_speed = 15.0,	max_speed = 125.0}
					]
				}

//	frigate_0: draft...
	frigate_0 =	{	name = tr("Frigate"), description = tr("(frégate)"),
					gears = [
						{ damping = 1.0,	max_thrust = 35.0,	max_angular_speed = 10.0,	max_speed = 35.0}
						{ damping = 1.0,	max_thrust = 60.0,	max_angular_speed = 10.0,	max_speed = 60.0}
						{ damping = 1.0,	max_thrust = 70.0,	max_angular_speed = 10.0,	max_speed = 70.0}
					]
				}
}

/*
GEAR1: 0.9/5/2.4 ( top speed:21m/s )
GEAR2: 0.9/50/2.4 ( topspeed:55m/s )
GEAR3: 0.9/75/2.4 ( topspeed:83m/s )

Orbiter:puissant, maniable, bonnes vitesses de base
GEAR1: 1/35/2 ( top speed:34m/s)
GEAR2: 1/60/2 ( topspeed:59m/s )
GEAR3: 1/70/2 ( topspeed:69m/s )

Drifter: tres rapide,  tourne tres vite, mais dur a piloter
GEAR1: 0.4/10/10 ( top speed:24m/s )
GEAR2: 0.4/25/10 ( topspeed:61m/s )
GEAR3: 0.4/50/10 ( topspeed:124m/s )
*/