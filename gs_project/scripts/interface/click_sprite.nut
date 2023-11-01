
Include ("scripts/interface/basic_sprite.nut")
/*!
	@short	ClickSprite
	@author	Scorpheus
*/
class	ClickSprite extends BasicSprite
{		
	text = 0
	unit = 0
	
	////////////////////////////////////////////////////////////////////////
	
	function UpdateLostContent()
	{
		base.UpdateLostContent()
		
		foreach(sprite in array_sprite)
			UIDeleteSprite(g_WindowsManager.current_ui, sprite)
		array_sprite.clear()
		array_sprite_relative_pos.clear()
		CreateSpriteWithText(text)
	}
	
	////////////////////////////////////////////////////////////////////////
	
	function Update(_with_all_children = false)
	{
		base.Update(_with_all_children)
	}
	
	////////////////////////////////////////////////////////////////////////
	
	function SerializationLoad(serialization_table)
	{
		text = serialization_table["text"]
		base.SerializationLoad(serialization_table)
		
		CreateSpriteWithText(text)	
	}	
	function SerializationSave()
	{
		local serialization_string = "text=\""+ text.tostring()+"\", "
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
	
	function Show(_with_all_children = false)
	{
		base.Show(_with_all_children)
		RefreshValueText(text, true)
	}
	////////////////////////////////////////////////////////////////////////

	function	RefreshValueText(_text, _force=false)
	{
		if(array_picture.len() <= 0 )
		{
			text = _text
			return
		}
		
		if(text.tostring().len() != _text.tostring().len())
		{ 
			local new_rect = TextComputeRect(Rect(0,0,9999,9999), _text.tostring()+" "+unit.tostring(), "simu_font", { size = g_size_font_text })
			PictureResize(array_picture["text_part"], new_rect.ex.tointeger(), SpriteGetSize(array_sprite["text_part"]).y.tointeger())
			SpriteSetSize(array_sprite["text_part"], new_rect.ex.tointeger(), SpriteGetSize(array_sprite["text_part"]).y.tointeger())		

			SetSize(width, height)	
		}

		if(!_force && (!is_shown || _text == text))
		{
			text = _text
			return
		}

		text = _text
		PictureFill(array_picture["text_part"], Vector(0.0,0.0,0.0,0.0))
		PictureTextRender(array_picture["text_part"], Rect(0, 10, SpriteGetSize(array_sprite["text_part"]).x, SpriteGetSize(array_sprite["text_part"]).y),  text.tostring()+" "+unit.tostring(), "simu_font" ,{ size = g_size_font_text, color = g_size_font_color_text })					
		TextureUpdate(array_texture["text_part"], array_picture["text_part"])			
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
	
	function SetPos(_pos)
	{		
			base.SetPos(_pos)	
	}
	function SetSize(_width, _height, _child=0)
	{
		local old_width = width
		
		base.SetSize(_width, height, _child)	
		
		if(array_sprite.len() > 0)
		{			
			array_sprite_relative_pos["right_part"].x += width - old_width
		
			// change size of the middle
			local old_width_middle = SpriteGetSize(array_sprite["middle_part"]).x
			SpriteSetSize(array_sprite["middle_part"], SpriteGetSize(array_sprite["middle_part"]).x+(width - old_width) , SpriteGetSize(array_sprite["middle_part"]).y)			
			
			SpriteSetSize(array_sprite["click_part"], width, height)

			if(alignment == "left")
				array_sprite_relative_pos["text_part"].x = SpriteGetSize(array_sprite["left_part"]).x
			else
			if(alignment == "center")
				array_sprite_relative_pos["text_part"].x = SpriteGetSize(array_sprite["left_part"]).x + SpriteGetSize(array_sprite["middle_part"]).x*0.5-SpriteGetSize(array_sprite["text_part"]).x*0.5
			else
			if(alignment == "right")
				array_sprite_relative_pos["text_part"].x = width-SpriteGetSize(array_sprite["text_part"]).x-SpriteGetSize(array_sprite["right_part"]).x
				
			SetPos(pos)
			
		//	SpriteSetScale(array_sprite[1], (old_width_middle.tofloat()/SpriteGetSize(array_sprite[1]).x.tofloat()), 1.0)					
		//	WindowSetCommandList(array_sprite[1],"toscale 0.3,1.0,1.0;")
		}
		else
			CreateSpriteWithText(text, width)	
						
	}					
	
	////////////////////////////////////////////////////////////////////////
	
	function CreateSpriteWithText(_text, _max_width = -1)
	{				
		CleanSprites()

		local left_picture = PictureNew()
		PictureLoadContent(left_picture, g_skin[skin].left_picture)
		local middle_picture = PictureNew()
		PictureLoadContent(middle_picture, g_skin[skin].middle_picture)	
		local right_picture = PictureNew()
		PictureLoadContent(right_picture, g_skin[skin].right_picture)
		
		// get the rect occupied by the text
		local MiddleRect = TextComputeRect(Rect(0,0,9999,9999), _text.tostring()+" "+unit.tostring(), "simu_font", { size = g_size_font_text })
		MiddleRect.ey = PictureGetRect(middle_picture).ey
		if(_max_width != -1)
			MiddleRect.ex = _max_width - (PictureGetRect(left_picture).ex + PictureGetRect(right_picture).ex)
		
		MiddleRect.ex = MiddleRect.ex.tointeger()
		MiddleRect.ey = MiddleRect.ey.tointeger()
			
		if(MiddleRect.ex < 1)
			MiddleRect.ex = 1

		width = PictureGetRect(left_picture).ex + MiddleRect.ex + PictureGetRect(right_picture).ex
		height = PictureGetRect(right_picture).ey
			
		// blit left part
		{
			local texture = ResourceFactoryNewTexture(g_factory)		
			TextureUpdate(texture, left_picture)
			TextureSetWrapping(texture, false,false)
			local relative_pos = Vector(0,0,0)
			array_texture.rawset("left_part", texture)
			array_sprite.rawset("left_part", UIAddSprite(g_WindowsManager.current_ui, -1, texture, pos.x+relative_pos.x, pos.y+relative_pos.y, PictureGetRect(left_picture).ex, PictureGetRect(left_picture).ey))
			array_sprite_relative_pos.rawset("left_part", relative_pos)			
		}
		// blit the middle part
		{		
			local texture = ResourceFactoryNewTexture(g_factory)	
			local pict = PictureNew()		
			PictureAlloc(pict, 1 , MiddleRect.ey)			
			
			PictureBlitRect(middle_picture, pict, PictureGetRect(middle_picture), Rect(0,0, PictureGetRect(middle_picture).ex, PictureGetRect(middle_picture).ey), BlendCompose)
			
			TextureUpdate(texture, pict)
			TextureSetWrapping(texture, true,false)
			local relative_pos = Vector(PictureGetRect(left_picture).ex,0,0)
			array_texture.rawset("middle_part", texture)
			array_sprite.rawset("middle_part", UIAddSprite(g_WindowsManager.current_ui, -1, texture, pos.x+relative_pos.x, pos.y+relative_pos.y, MiddleRect.ex , MiddleRect.ey))
			array_sprite_relative_pos.rawset("middle_part", relative_pos)			
		}
		// blit right part
		{
			local texture = ResourceFactoryNewTexture(g_factory)		
			TextureUpdate(texture, right_picture)
			TextureSetWrapping(texture, false,false)
			local relative_pos = Vector(PictureGetRect(left_picture).ex+MiddleRect.ex,0,0)
			array_texture.rawset("right_part", texture)
			array_sprite.rawset("right_part", UIAddSprite(g_WindowsManager.current_ui, -1, texture, pos.x+relative_pos.x, pos.y+relative_pos.y, PictureGetRect(right_picture).ex, PictureGetRect(right_picture).ey))
			array_sprite_relative_pos.rawset("right_part", relative_pos)			
		}
		// blit text part
		{
			local texture = ResourceFactoryNewTexture(g_factory)	
			local pict = PictureNew()					
			PictureAlloc(pict, MiddleRect.ex , MiddleRect.ey)			
			PictureTextRender(pict, Rect(0, 10, MiddleRect.ex, MiddleRect.ey), _text.tostring()+" "+unit.tostring(), "simu_font" ,{ size = g_size_font_text, color = g_size_font_color_text })
			
			TextureUpdate(texture, pict)
			TextureSetWrapping(texture, false,false)
			local relative_pos = Vector(PictureGetRect(left_picture).ex,0,0)
			array_texture.rawset("text_part", texture)
			array_picture.rawset("text_part", pict)	
			array_sprite_relative_pos.rawset("text_part", relative_pos)	

			if(alignment == "left")
				array_sprite_relative_pos["text_part"].x = SpriteGetSize(array_sprite["left_part"]).x
			else
			if(alignment == "center")
				array_sprite_relative_pos["text_part"].x = SpriteGetSize(array_sprite["left_part"]).x // it's the same as the left, because when created the widget has a good size
			else
			if(alignment == "right")
				array_sprite_relative_pos["text_part"].x = width-MiddleRect.ex-SpriteGetSize(array_sprite["right_part"]).x
						
			array_sprite.rawset("text_part", UIAddSprite(g_WindowsManager.current_ui, -1, texture, pos.x+array_sprite_relative_pos["text_part"].x, pos.y+array_sprite_relative_pos["text_part"].y, MiddleRect.ex , MiddleRect.ey))
			
		}		
								
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
	
	function	constructor(_id = 0, _parent = 0, _instance=0, _func="", _text ="", _unit="")
	{	
		type = "ClickSprite"		
		base.constructor(_id, _parent)		
		
		text = _text
		unit = _unit	
		alignment			=	"center"
		CreateSpriteWithText(text)	
		
		if(_instance && typeof(_func) == "string" && _func.len() > 0)
			array_instance_function_callback.append({instance=_instance,func_name=_func})
	}
}
