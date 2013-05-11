/*
	File: scripts/ship.nut
	Author: P. Blanche - F. Gutherz
*/

Include("scripts/utils/physic_item_gravity_source.nut")

/*!
	@short	Asteroid
	@author	P. Blanche - F. Gutherz
*/
class	Asteroid	extends	PhysicItemGravitySource
{
	player_item						=	0
	split_to_instances_list			=	0

	function	OnUpdate(item)
	{
		if ("OnUpdate" in base)	base.OnUpdate(item)		
	}

	function	RenderUser(scene)
	{
		if ("RenderUser" in base)	base.RenderUser(scene)
	}

	function	OnSetup(item)
	{
		if ("OnSetup" in base)	base.OnSetup(item)
		player_item = SceneFindItem(g_scene, "ship")
		SceneGetScriptInstance(g_scene).render_user_callback.append(this)
		if (split_to_instances_list == 0)
			split_to_instances_list = []
	}
}
