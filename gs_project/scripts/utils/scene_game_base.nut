/*
	File: scripts/utils/scene_game.nut
	Author: P. Blanche - F. Gutherz
*/

Include("scripts/interface/basic_sprite.nut")

/*!
	@short	SceneGame
	@author	P. Blanche - F. Gutherz
*/
class	SceneGameBase
{
	ui						=	0
	master_ui_sprite		=	0
	hidden_ui				=	false

	keyboard_device			=	0

	/*!
		@short	OnSetup
		Called when the scene is about to be setup.
	*/
	function	OnSetup(scene)
	{
		if (!("g_cursor" in getroottable()))
			return

		//	Input devices
		keyboard_device = GetInputDevice("keyboard")

		//	UI
		g_cursor = CCursor()
		g_cursor.Setup()
		ui = SceneGetUI(scene)
		g_cursor.ui = ui
		g_WindowsManager = WindowsManager()
		g_WindowsManager.current_ui = SceneGetUI(scene)

		//	Master UI Sprite (to hide the UI globally)
		master_ui_sprite = BasicSprite()

		//	Physic
		SceneSetGravity(scene, Vector(0,0,0))
	}

	function	ToggleMasterUI()
	{
		if (hidden_ui)
			master_ui_sprite.SetOpacity(1.0)
		else
			master_ui_sprite.SetOpacity(0.0)

		hidden_ui = !hidden_ui
	}

	function	OnUpdate(scene)
	{
		if (("g_cursor" in getroottable()) && g_cursor != 0)
			g_cursor.Update()

		if (!DeviceWasKeyDown(keyboard_device, KeyEscape) && DeviceIsKeyDown(keyboard_device, KeyEscape))
			ToggleMasterUI()
	}
}
