
Include ("scripts/interface/basic_sprite.nut")
/*!
	@short	HorizontalSizerSprite
	@author	Scorpheus
*/
class	HorizontalSizerSprite extends BasicSprite
{					
	width_total_child = 0
	
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
			temp_pos.x += child.width + decal_sprite_x
		}				

		if("little_shadow_sprite" in array_sprite)
			SpriteSetScale(array_sprite["little_shadow_sprite"], width.tofloat()/ SpriteGetSize(array_sprite["little_shadow_sprite"]).x, 1.0)
	}
	function SetSize(_width, _height, _child=0)
	{
		base.SetSize(_width, height, _child)
				
		if(child_array.len() > 0)
		{		
			local max_width = width
			width_total_child = 0
			foreach(child in child_array)
				if(child.authorize_resize)
					width_total_child += child.original_width
				else
					max_width -= child.original_width

			if("little_shadow_sprite" in array_sprite)
			{
				local max_height = 0
				foreach(child in child_array)
					if(max_height < child.original_height)
						max_height = child.original_height

				array_sprite_relative_pos.rawset("little_shadow_sprite", Vector(0.0, max_height, 0.0))	
			}
					
			if(width_total_child > 0)
			{
				foreach(child in child_array)
				{
					child.SetSize((child.original_width * max_width) / width_total_child, height)
				}				
			}
			
			// all child has space, put them at good distance
			SetPos(pos)
		}		
	}		
	
	////////////////////////////////////////////////////////////////////////
	
	function AppendChild(_child)
	{
		base.AppendChild(_child)
		
		// check if the child has bigger height
		if(_child.height > height)
			original_height = height = _child.height
		
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
		type = "HorizontalSizerSprite"	

		width_total_child = 0

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
