// this file is to set properly and only once global values
// use the global_setup and global_update function once

Include ("scripts/utils/utils.nut")

root_table <- getroottable()

// load the translator
if(!("g_translation_db" in root_table))
	Include("scripts/locale/locale_function.nut")

// load the cursor
if(!("g_cursor" in root_table))
{	
	Include("scripts/utils/cursor.nut")
	g_cursor <- CCursor()
}

// load the g_WindowsManager
if(!("g_WindowsManager" in root_table))
{	
	Include("scripts/interface/windows_manager.nut")
	g_WindowsManager <- WindowsManager()
}

// load the g_MainCamera
if(!("g_MainCamera" in root_table))
{	
	Include("scripts/main_camera.nut")
	g_MainCamera <- MainCamera()
}

// load the g_SoundManager
if(!("g_SoundManager" in root_table))
{	
	Include("scripts/sound_manager.nut")
	g_SoundManager <- SoundManager()
}

// load the g_Debug2dManager
if(!("g_Debug2dManager" in root_table))
{	
	Include("scripts/utils/debug_2d_manager.nut")
	g_Debug2dManager <- Debug2dManager()
}

// load the g_SimuFont
if(!("g_SimuFont" in root_table))
{	
	ProjectLoadUIFontAliased(g_project, "ui/simu_font.ttf", "simu_font")
	g_SimuFont <- ResourceFactoryLoadRasterFont(g_factory, "ui/profont.nml", "ui/profont")
}

// do the setup only once
if(!("g_GlobalSetupOnce" in root_table))
	g_GlobalSetupOnce <- false
	
function GlobalSetup()
{	
	// setup cursor
	g_cursor.Setup()
	
	if(g_GlobalSetupOnce)
		return

	g_SoundManager.Setup()
		
	g_GlobalSetupOnce = true
	
	
	// setup the windows manager
	g_WindowsManager.Setup()
	
}

function GlobalUpdate()
{
	// update cursor
	g_cursor.Update()	
	
	// update car camera
	g_MainCamera.Update()		
	
	// update g_SoundManager
	g_SoundManager.Update()	

	g_WindowsManager.Update(true)

	
}

class	GlobalItemUpdateScript
{	
	function	OnRenderUser(scene)
	{
		g_Debug2dManager.OnRenderUser(scene)
	}

	/*! @short	OnRenderDone Called each frame. */ 
	function	OnRenderDone(item) 
	{
	}

	/*! @short	OnUpdate Called each frame. */ 
	function	OnUpdate(item) 
	{
		GlobalUpdate()
	}
		
	function 	OnSetup(Item)
	{		
		GlobalSetup()	
	}
}		


function	ConformString(str)
{
	local	l = str.len(), i,
			nstr = "", c
	
	for (i = 0; i < l; i++)
	{
		c = str.slice(i,i+1)
		if ((c >= "a" && c <= "z") || (c >= "A" && c <= "Z") || (c >= "0" && c <= "9")) 
			nstr += c
		else
			nstr += "_"
	}		
	
	return (nstr)
}
