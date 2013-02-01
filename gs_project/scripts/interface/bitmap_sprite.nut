
Include ("scripts/interface/basic_sprite.nut")
/*!
	@short	BitmapSprite
	@author	Scorpheus
*/
class	BitmapSprite extends BasicSprite
{		
	name_sprite = 0

	scaleX = 0
	scaleY = 0


	////////////////////////////////////////////////////////////////////////
	
	function SetAlpha(_alpha)
	{		
		SpriteSetOpacity(array_sprite["bitmap_part"], _alpha)	
	}
	////////////////////////////////////////////////////////////////////////
	
	function UpdateLostContent()
	{
		base.UpdateLostContent()
		
		foreach(sprite in array_sprite)
			UIDeleteSprite(g_WindowsManager.current_ui, sprite)
		array_sprite.clear()
		array_sprite_relative_pos.clear()
		CreateBitmap(name_sprite)
	}
	
	////////////////////////////////////////////////////////////////////////
	
	function Update(_with_all_children = false)
	{
		base.Update(_with_all_children)
	}
	
	////////////////////////////////////////////////////////////////////////
	
	function SerializationLoad(serialization_table)
	{
		name_sprite = serialization_table["name_sprite"]
		base.SerializationLoad(serialization_table)
		
		CreateBitmap(name_sprite)	
	}	
	function SerializationSave()
	{
		local serialization_string = "name_sprite=\""+ name_sprite.tostring()+"\", "
		serialization_string += base.SerializationSave()			
		
		return serialization_string
	}
		
	////////////////////////////////////////////////////////////////////////
	
	function	CursorEnterEvent(event, table)
	{
		if(hover_animation == "expand")
		{
			//	print("enter")
				original_width += 50
				SetSize(original_width, height)
				
			if(parent)
				parent.SetSize(parent.width, parent.height, this)
		}
	}
	function	CursorLeaveEvent(event, table)
	{			
		if(hover_animation == "expand")
		{		
			//	print("leave")
				original_width -= 50
				SetSize(original_width, height)
				
			if(parent)
				parent.SetSize(parent.width, parent.height, this)
		}
	}
	
	////////////////////////////////////////////////////////////////////////
	
	function CallCallback(_value=0)
	{
		foreach(instance_callback in array_instance_function_callback)
		{
			if(instance_callback.func_name in instance_callback.instance)
			{
				instance_callback.instance[instance_callback.func_name](this)
			}
		}
	}
	
	////////////////////////////////////////////////////////////////////////

	function	RefreshValueText()
	{
	}

	////////////////////////////////////////////////////////////////////////
	
	function	ClickUpEvent(event, table)
	{
		base.ClickUpEvent(event, table)
		UIUnlock(g_WindowsManager.current_ui)
	}
	
	function	ClickDownEvent(event, table)
	{
		base.ClickDownEvent(event, table)
		UILockToSprite(g_WindowsManager.current_ui, array_sprite["click_part"])
	}
	
	////////////////////////////////////////////////////////////////////////
	
	function	ClickButtonEvent(event, table)
	{
		// if it's right click
		local ui_device = GetInputDevice("mouse")
		if(DeviceIsKeyDown(ui_device, KeyButton1))
			return
		
		CallCallback()
	}
	
	////////////////////////////////////////////////////////////////////////
	
	function SetPos(_pos)
	{		
		base.SetPos(_pos)	
	}
	function SetSize(_width, _height, _child=0)
	{
		local old_width = width
		
		base.SetSize(_width, _height, _child)	
		
		if(array_sprite.len() > 0)
		{		
			SetPos(pos)
		}
		else
			CreateBitmap(text)	
						
	}		
	function SetScale(_scaleX, _scaleY, _child=0)
	{
		scaleX = _scaleX
		scaleY = _scaleY
		if(array_sprite.len() > 0)
		{		
			SpriteSetScale(array_sprite["click_part"], scaleX, scaleY)	
			SpriteSetScale(array_sprite["bitmap_part"], scaleX, scaleY)	
		}
		else
			CreateBitmap(text)	
						
	}					
	
	////////////////////////////////////////////////////////////////////////
	
	function CreateBitmap( _name_sprite)
	{			
		CleanSprites()

		local bitmap_picture = PictureNew()
		PictureLoadContent(bitmap_picture, _name_sprite)

		// blit bitmap part
		{
			local texture = ResourceFactoryNewTexture(g_factory)		
			TextureUpdate(texture, bitmap_picture)
			TextureSetWrapping(texture, false,false)
			local relative_pos = Vector(0,0,0)
			array_texture.rawset("bitmap_part", texture)
			array_picture.rawset("bitmap_part", bitmap_picture)
			array_sprite.rawset("bitmap_part", UIAddSprite(g_WindowsManager.current_ui, -1, texture, pos.x+relative_pos.x, pos.y+relative_pos.y, PictureGetRect(bitmap_picture).ex, PictureGetRect(bitmap_picture).ey))
			array_sprite_relative_pos.rawset("bitmap_part", relative_pos)			
		}
		
		width = PictureGetRect(bitmap_picture).ex
		height = PictureGetRect(bitmap_picture).ey
						
		// add click section
		{
			local texture = ResourceFactoryNewTexture(g_factory)	
			TextureSetWrapping(texture, false,false)
			local relative_pos = Vector(0,0,0)
			array_texture.rawset("click_part", texture)
			local sprite = UIAddSprite(g_WindowsManager.current_ui, -1, texture, pos.x+relative_pos.x, pos.y+relative_pos.y, width, height)
			array_sprite.rawset("click_part", sprite)
			array_sprite_relative_pos.rawset("click_part", relative_pos)		
			
			SpriteSetEventHandlerWithContext(sprite, EventCursorDown, this, ClickDownEvent)
			SpriteSetEventHandlerWithContext(sprite, EventCursorUp, this, ClickUpEvent)
			SpriteSetEventHandlerWithContext(sprite, EventCursorMove, this, MouseMouseEvent)
			
			SpriteSetEventHandlerWithContext(sprite, EventCursorEnter, this, CursorEnterEvent)
			SpriteSetEventHandlerWithContext(sprite, EventCursorLeave, this, CursorLeaveEvent)						
		}
	}
		
	////////////////////////////////////////////////////////////////////////
	
	function	constructor(_id = 0, _parent = 0, _instance=0, _func="", _name_sprite ="")
	{	
		type = "BitmapSprite"		
		base.constructor(_id, _parent)	

		scaleX = 1.0
		scaleY = 1.0	
			
		name_sprite = _name_sprite
		CreateBitmap(name_sprite)	
		
		if(_instance && typeof(_func) == "string" && _func.len() > 0)
			array_instance_function_callback.append({instance=_instance,func_name=_func})
	}
}
