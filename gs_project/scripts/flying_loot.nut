/*
	File: scripts/flying_loot.nut.nut
	Author: P. Blanche - F. Gutherz
*/

Include("scripts/utils/physic_item_gravity_source.nut")

/*!
	@short	FlyingLoot
	@author	P. Blanche - F. Gutherz
*/
class	FlyingLoot	extends	PhysicItemGravitySource
{
/*<
	<Parameter =
		<absorption_factor = <Name = "Absorption factor"> <Description = "How much of the bullet energy actually hits the loot. (0.0 = unbreakable, 1.0 = dies on 1st hit)"> <Type = "float"> <Default = 1.0>>
		<split_to_instances_list = <Name = "Instances list"> <Description = "List of scene instances to spawn when the item is destroyed, split by a semi colon."> <Type = "string"> <Default = "">>
	>
>*/
	//	Gameplay members
	energy							=	1.0
	absorption_factor				=	1.0		//	How much of the bullet energy actually hits the loot. (0.0 = unbreakable, 1.0 = dies on 1st hit).
	died							=	false

	//
	player_item						=	0
	split_to_instances_list			=	""

	/*
		The loot takes a hit
	*/
	function	TakeHit(_damage)
	{
		energy -= _damage * absorption_factor
		if (energy <= 0.0)
		{
			energy = 0.0
			Die()
		}
	}

	/*
		The loot finally dies and disappears
	*/
	function	Die()
	{
		if (died)
			return

		SceneGetScriptInstance(g_scene).ship_control_handler.TestAutopilotTargetValidity(body)
		g_split_manager.ItemSplitIntoInstances(body, ItemGetScriptInstance(body).linear_velocity)
		g_particle_emitter.EmitCircle(body, 4.0, 0.35, g_vector_orange)
		g_particle_emitter.EmitCircle(body, 0.8, 1.1, g_vector_orange)

		died = true
	}

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

		died = false
		player_item = SceneFindItem(g_scene, "ship")
		SceneGetScriptInstance(g_scene).render_user_callback.append(this)
		if (split_to_instances_list == "" || (typeof split_to_instances_list != "string"))
			split_to_instances_list = []
		else
			split_to_instances_list = split(split_to_instances_list,";")
	}
}
