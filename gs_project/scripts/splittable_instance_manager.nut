/*
	File: scripts/utils/splittable_instance_manager.nut
	Author: P. Blanche - F. Gutherz
*/

/*!
	@short	SplittableInstanceManager
	@author	P. Blanche - F. Gutherz
*/
class	SplittableInstanceManager
{
	scene					=	0

	items_to_deactivate		=	0
	items_to_delete			=	0
	items_to_create			=	0

	particle_emitter		=	0
	

	function	ItemSplitIntoInstances(_item, velocity = Vector())
	{
		local	_split_items_list = []
		if (ItemHasScript(_item, "FlyingLoot"))
		{
			print("SplittableInstanceManager::ItemSplitIntoInstances() : found script instance.")
			local	_script = ItemGetScriptInstance(_item)
			if ("split_to_instances_list" in _script)
			{
				print("SplittableInstanceManager::ItemSplitIntoInstances() : found a list of " + _script.split_to_instances_list.len().tostring() + "items.")
				foreach(_split_item in _script.split_to_instances_list)
				{
					//	append _split_item to items_to_create
					_split_items_list.append("assets/" + _split_item)
				}
			}
		}

		//	prepare the item for deactivation
		items_to_deactivate.append({ item = _item, position = ItemGetWorldPosition(_item), split_items_list = _split_items_list})
	}

	function	Update()
	{
		//	Items to delete
		foreach(_idx, _item in items_to_delete)
		{
			SceneDeleteItemHierarchy(scene, _item.item)
			items_to_create.append(_item)
			items_to_delete.remove(_idx)
		}

		//	Items to deactivate
		foreach(_idx, _item in items_to_deactivate)
		{
			particle_emitter.EmitCircle(_item.item)

			local	_item_parent = ItemGetParent(_item.item)
			if (ObjectIsValid(_item_parent))
				_item.item = _item_parent

			items_to_delete.append(_item)

			ItemSetSelfMask(_item.item, 0)
			ItemSetCollisionMask(_item.item, 0)

			items_to_deactivate.remove(_idx)
		}

		//	New items to create
		foreach(_idx, _item in items_to_create)
		{
/*
	//	Disabled until the engine is able to import a physics instance again :)

			foreach(_path_item in _item.split_items_list)
			{
				print("SplittableInstanceManager::Update() Spawning '" + _path_item)
				local	_group = SceneLoadAndStoreGroup(scene, _path_item, ImportFlagObject) 
				GroupRenderSetup(_group, g_factory)
				GroupSetup(_group)
				GroupSetupScript(_group)
				local	_list = GroupGetItemList(_group)
				local	_new_item = _list[0]
				local	_pos = _item.position
				print("SplittableInstanceManager::Update() Moving item : " + ItemGetName(_new_item))
				ItemSetParent(_new_item, NullItem)
				ItemSetPosition(_new_item, _pos)
				ItemPhysicResetTransformation(_new_item, _pos, Vector(0, DegreeToRadian(Rand(-180.0,180.0)), 0))
				ItemWake(_new_item)
			}
*/	
			items_to_create.remove(_idx)
		}

		particle_emitter.Update()
	}

	function	Delete()
	{
		items_to_deactivate = []
		items_to_delete = []
		items_to_create = []
	}

	constructor(_scene)
	{
		scene = _scene

		items_to_deactivate = []
		items_to_delete = []
		items_to_create = []
		particle_emitter = ParticleEmitter()
	}

}
