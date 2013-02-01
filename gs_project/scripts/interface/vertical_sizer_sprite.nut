
Include ("scripts/interface/basic_sprite.nut")
/*!
	@short	VerticalSizerSprite
	@author	Scorpheus
*/
class	VerticalSizerSprite extends BasicSprite
{					
	height_total_child = 0	

	////////////////////////////////////////////////////////////////////////
	
	function Update(_with_all_children = false)
	{
		base.Update(_with_all_children)
	}
	
	////////////////////////////////////////////////////////////////////////
	
	function SerializationLoad(serialization_table)
	{
		base.SerializationLoad(serialization_table)
	}	
	function SerializationSave()
	{
		local serialization_string = base.SerializationSave()
		return serialization_string
	}
					
	////////////////////////////////////////////////////////////////////////
	
	function SetPos(_pos)
	{
		base.SetPos(_pos)
		
		// all child has space, put them at good distance
		local temp_pos = clone(pos)				
		foreach(child in child_array)
		{
			child.SetPos(temp_pos)
			temp_pos.y += child.height
		}				

		if("little_shadow_sprite" in array_sprite)
			SpriteSetScale(array_sprite["little_shadow_sprite"], width.tofloat()/ SpriteGetSize(array_sprite["little_shadow_sprite"]).x, 1.0)
		
	}
	function SetSize(_width, _height, _child=0)
	{
		base.SetSize(_width, _height, _child)

		if(child_array.len() > 0)
		{		
			height_total_child = 0
			foreach(child in child_array)
				height_total_child += child.original_height					

			if("little_shadow_sprite" in array_sprite)
				array_sprite_relative_pos.rawset("little_shadow_sprite", Vector(0.0, height_total_child, 0.0))	

			if(height_total_child > 0)
			{
				foreach(child in child_array)
				{
					child.SetSize(width, (child.original_height * height) / height_total_child)
				}				
			}

			original_height = height_total_child
			
			// all child has space, put them at good distance	
			SetPos(pos)
		}		
	}		
	
	////////////////////////////////////////////////////////////////////////
	
	function AppendChild(_child)
	{
		base.AppendChild(_child)
		
		// check if the child has bigger width
		if(_child.width > width)
			original_width = width = _child.width
			
		SetSize(width, height)
		
		if(parent)
			parent.SetSize(parent.width, parent.height, this)
	}
	function RemoveChild(_id)
	{		
		base.RemoveChild(_id)		
	}
		
	////////////////////////////////////////////////////////////////////////
	
	function Kill(_with_child)
	{
		base.Kill(_with_child)
	}
	
	////////////////////////////////////////////////////////////////////////
	
	function	constructor( _id = 0, _parent = 0)
	{			
		base.constructor(_id, _parent)
		type = "VerticalSizerSprite"		
		
		height_total_child = 0

		// create the little shadow
		if(!parent)
		{
			local pict_little_shadow = PictureNew()
			PictureLoadContent(pict_little_shadow, "ui/window_bottom_shadow.tga")
			local texture = ResourceFactoryNewTexture(g_factory)		
			TextureUpdate(texture, pict_little_shadow)
			TextureSetWrapping(texture, true,false)
			array_sprite.rawset("little_shadow_sprite", UIAddSprite(g_WindowsManager.current_ui, -1, texture, pos.x, pos.y+height, PictureGetRect(pict_little_shadow).ex, PictureGetRect(pict_little_shadow).ey))
			array_sprite_relative_pos.rawset("little_shadow_sprite", Vector(0.0, height, 0.0))	
		}
	}
}
