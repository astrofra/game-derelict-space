/*
	File: scripts/utils/scene_game.nut
	Author: P. Blanche - F. Gutherz
*/

Include("scripts/utils/scene_game_base.nut")
Include("scripts/camera_game.nut")
Include("scripts/starfield.nut")
Include("scripts/ship_control.nut")
Include("scripts/settings_table_ship.nut")
Include("scripts/particle_emitter.nut")
Include("scripts/splittable_instance_manager.nut")

if (!("ship_name" in getroottable()))
	ship_name					<-	"arrow"

if (!("g_particle_emitter" in getroottable()))
	g_particle_emitter			<-	0

if (!("g_split_manager" in getroottable()))
	g_split_manager				<-	0


/*!
	@short	SceneGame
	@author	P. Blanche - F. Gutherz
*/
class	SceneGame	extends SceneGameBase
{
	player_item				=	0
	camera_handler			=	0
	starfield_handler		=	0
	ship_control_handler	=	0

	ship_direction			=	0

	ship_group				=	0
	ships					=	0

	render_user_callback	=	0

	/*!
		@short	OnUpdate
		Called each frame.
	*/
	function	OnUpdate(scene)
	{
		if ("OnUpdate" in base)	base.OnUpdate(scene)

		local	mouse_device = GetInputDevice("mouse")
	
		ship_control_handler.Update()

		local	mouse_wheel = DeviceInputValue(mouse_device, DeviceAxisRotY)
		camera_handler.OffsetCameraY(mouse_wheel * Mtr(-15.0))
		starfield_handler.SetSize(camera_handler.target_pos_offset.y)

		if (g_particle_emitter != 0)
			g_particle_emitter.Update()

		if (g_split_manager  != 0)
			g_split_manager.Update()

		//camera_handler.Update(player_item)
	}

	function	OnRenderUser(scene)
	{
		RendererSetIdentityWorldMatrix(g_render)
		starfield_handler.Update(camera_handler.position)

		foreach(_callback in render_user_callback)
			_callback["RenderUser"](scene)

		if (g_particle_emitter != 0)
			g_particle_emitter.RenderUser()
	}

	function	ShipSelectorMenu()
	{
		local	top_window = g_WindowsManager.CreateVerticalSizer(0, 1000)
		top_window.SetParent(master_ui_sprite)
		top_window.SetPos(Vector(8, 256, 0))

		ships = []
		ships.append({name = "arrow", button = 0})
		ships.append({name = "orbiter", button = 0})
		ships.append({name = "drifter", button = 0})
		ships.append({name = "frigate_0", button = 0})
		ships.append({name = "frigate_1", button = 0})
		ships.append({name = "frigate_2", button = 0})

		for(local n = 0; n < ships.len();n++)
		{
			local	_bt
 			_bt = g_WindowsManager.CreateCheckButton(top_window, ships[n].name, ship_name == ships[n].name?true:false, this, "ClickOnShip")
			_bt.authorize_resize = false
			ships[n].button = _bt
		}
	}

	function	ClickOnShip(_sprite)
	{
		foreach(_idx, _ship in ships)
		{
			_ship.button.RefreshValueText(false)
			if (_ship.button == _sprite)
				ship_name = _ship.name
		}

		_sprite.RefreshValueText(true)

		SceneEnd(g_scene)
		ProjectGetScriptInstance(g_project).dispatch =  ProjectGetScriptInstance(g_project).ReloadScene
	}

	function	SpawnShip(scene)
	{
		if (ship_group != 0)
			SceneDeleteGroup(scene, ship_group)

		local	spawnpoint = SceneFindItem(scene, "spawnpoint")
		ship_group = SceneLoadAndStoreGroup(scene, "assets/" + ship_name + ".nms", ImportFlagAll & ~ImportFlagGlobals)
		GroupRenderSetup(ship_group, g_factory)
		player_item = GroupFindItem(ship_group, "ship")
		local	_list = GroupGetItemList(ship_group)
//		foreach(_item in _list)
//			SceneSetupItem(scene, _item)
	}

	/*!
		@short	OnSetup
		Called when the scene is about to be setup.
	*/
	function	OnSetup(scene)
	{
		if ("OnSetup" in base)	base.OnSetup(scene)
		render_user_callback = []

		ShipSelectorMenu()

		camera_handler = CameraGame(scene)
		SpawnShip(scene)
//		player_item = SceneFindItem(scene, "ship")
		ship_control_handler = ShipControl(scene)
		starfield_handler = Starfield()

		ship_direction = g_zero_vector
		
		g_particle_emitter = ParticleEmitter()
		g_split_manager = SplittableInstanceManager(scene)
	}
}
