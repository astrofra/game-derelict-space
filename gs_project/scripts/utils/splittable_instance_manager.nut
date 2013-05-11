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
	

	function	ItemSplitIntoInstances(item, velocity = Vector())
	{
		if (ItemHasScript(item, "PhysicItemXZPlane"))
		{
			local	_script = ItemGetScriptInstance(item)
			if ("split_to_instances_list" in _script)
			{
				foreach(_split_item in _script.split_to_instances_list)
				{
					//	append _split_item to items_to_create
				}
			}
		}

		//	prepare the item for deactivation
		items_to_deactivate.append(item)
	}

	function	Update()
	{
		//	Items to delete
		foreach(_idx, _item in items_to_delete)
		{
			SceneDeleteItemHierarchy(scene, _item)
			items_to_delete.remove(_idx)
		}

		//	Items to deactivate
		foreach(_idx, _item in items_to_deactivate)
		{
			local	_item_parent = ItemGetParent(_item)
			if (ObjectIsValid(_item_parent)
				items_to_delete.append(_item_parent)
			else
				items_to_delete.append(_item)

			ItemSetSelfMask(_item, 0)
			ItemSetCollisionMask(_item, 0)

			items_to_deactivate.remove(_idx)
		}

		//	New items to create
		foreach(_idx, _item in items_to_create)
		{
			items_to_create.remove(_idx)
		}
	}

	constructor(_scene)
	{
		scene = _scene

		items_to_deactivate = []
		items_to_delete = []
	}

}
